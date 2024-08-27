#!/bin/bash

# 引入參數
curlArgs="$useNIC $usePROXY $xForward $resolve $dns --max-time 10"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.64"

# 初始化结果JSON
results="{}"

# 函数用于将检测结果添加到JSON对象
add_result_to_json() {
    local key="$1"
    local value="$2"
    results=$(echo "$results" | jq --arg key "$key" --arg value "$value" '.[$key] = $value')
}

# 檢測 Now E
function MediaUnlockTest_NowE() {
    local result=$(curl $curlArgs -s --user-agent "$UA_Browser" -X POST -H "Content-Type: application/json" \
        -d '{"contentId":"202105121370235","contentType":"Vod","pin":"","deviceId":"W-60b8d30a-9294-d251-617b-6oagagn3","deviceType":"WEB"}' \
        "https://webtvapi.nowe.com/16/1/getVodURL")

    local responseCode=$(echo "$result" | jq -r '.responseCode // empty')

    if [[ "$responseCode" == "SUCCESS" || "$responseCode" == "PRODUCT_INFORMATION_INCOMPLETE" ]]; then
        add_result_to_json "Now E" "Yes"
    elif [[ "$responseCode" == "GEO_CHECK_FAIL" ]]; then
        add_result_to_json "Now E" "No"
    else
        add_result_to_json "Now E" "No"
    fi
}

# 檢測 Viu.TV
function MediaUnlockTest_ViuTV() {
    local tmpresult=$(curl $curlArgs -s --user-agent "$UA_Browser" -X POST -H "Content-Type: application/json" \
        -d '{"callerReferenceNo":"20210726112323","contentId":"099","contentType":"Channel","channelno":"099","mode":"prod","deviceId":"29b3cb117a635d5b56","deviceType":"ANDROID_WEB"}' \
        "https://api.viu.now.com/p8/3/getLiveURL")

    if [ -z "$tmpresult" ]; then
        add_result_to_json "Viu.TV" "No"
        return
    fi

    local responseCode=$(echo "$tmpresult" | jq -r '.responseCode // empty')

    if [[ "$responseCode" == "SUCCESS" ]]; then
        add_result_to_json "Viu.TV" "Yes"
    elif [[ "$responseCode" == "GEO_CHECK_FAIL" ]]; then
        add_result_to_json "Viu.TV" "No"
    else
        add_result_to_json "Viu.TV" "No"
    fi
}

# 檢測 MyTVSuper
function MediaUnlockTest_MyTVSuper() {
    local result=$(curl $curlArgs -s --user-agent "$UA_Browser" --max-time 10 "https://www.mytvsuper.com/api/auth/getSession/self/")

    local region=$(echo "$result" | jq -r '.region // empty')

    if [[ "$region" == "1" ]]; then
        add_result_to_json "MyTVSuper" "Yes"
    else
        add_result_to_json "MyTVSuper" "No"
    fi
}

# 檢測 HBO GO Asia
function MediaUnlockTest_HBOGO_ASIA() {
    local tmpresult=$(curl $curlArgs -s --user-agent "$UA_Browser" --max-time 10 "https://api2.hbogoasia.com/v1/geog?lang=undefined&version=0&bundleId=www.hbogoasia.com")

    if [ -z "$tmpresult" ]; then
        add_result_to_json "HBO GO Asia" "No"
        return
    fi

    local territory=$(echo "$tmpresult" | jq -r '.territory // empty')
    local country=$(echo "$tmpresult" | jq -r '.country // empty')

    if [ -n "$territory" ]; then
        add_result_to_json "HBO GO Asia" "Yes($country)"
    else
        add_result_to_json "HBO GO Asia" "No"
    fi
}

# 檢測 HOY TV
function MediaUnlockTest_HoyTV() {
    local result=$(curl $curlArgs -s --user-agent "$UA_Browser" -SsL --write-out %{http_code} --output /dev/null --max-time 10 "https://hoytv-live-stream.hoy.tv/ch78/index-fhd.m3u8")

    if [[ "$result" == "403" ]]; then
        add_result_to_json "HOY TV" "No"
    elif [[ "$result" == "200" ]]; then
        add_result_to_json "HOY TV" "Yes"
    else
        add_result_to_json "HOY TV" "No"
    fi
}

# 執行所有檢測
MediaUnlockTest_NowE
MediaUnlockTest_ViuTV
MediaUnlockTest_MyTVSuper
MediaUnlockTest_HBOGO_ASIA
MediaUnlockTest_HoyTV

# 輸出最终紧凑格式的JSON结果
echo "$results" | jq -c '.'

