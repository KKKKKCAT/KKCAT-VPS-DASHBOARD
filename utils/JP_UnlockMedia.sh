#!/bin/bash

# 引入参数
curlArgs="-4 -s --max-time 10"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.64"
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)"

# 检测 DMM TV
function MediaUnlockTest_DMMTV() {
    local tmpresult=$(curl $curlArgs --user-agent "$UA_Browser" -X POST -d '{"player_name":"dmmtv_browser","player_version":"0.0.0","content_type_detail":"VOD_SVOD","content_id":"11uvjcm4fw2wdu7drtd1epnvz","purchase_product_id":null}' "https://api.beacon.dmm.com/v1/streaming/start")

    if [[ "$tmpresult" == "curl"* ]] || [[ -z "$tmpresult" ]]; then
        echo "No"
        return
    fi

    local checkfailed=$(echo "$tmpresult" | grep 'FOREIGN')
    if [ -n "$checkfailed" ]; then
        echo "No"
        return
    fi

    local checksuccess=$(echo "$tmpresult" | grep 'UNAUTHORIZED')
    if [ -n "$checksuccess" ]; then
        echo "Yes"
        return
    else
        echo "No"
        return
    fi
}

# 检测 Abema TV
function MediaUnlockTest_AbemaTV() {
    local tempresult=$(curl $curlArgs --user-agent "$UA_Dalvik" -fsL "https://api.abema.io/v1/ip/check?device=android")

    if [[ "$tempresult" == "curl"* ]] || [[ -z "$tempresult" ]]; then
        echo "No"
        return
    fi

    local result=$(echo "$tempresult" | jq -r '.isoCountryCode // empty')
    if [ -n "$result" ]; then
        if [[ "$result" == "JP" ]]; then
            echo "Yes"
        else
            echo "Oversea Only(${result})"
        fi
    else
        echo "No"
    fi
}

# 检测 Niconico
function MediaUnlockTest_Niconico() {
    local result=$(curl $curlArgs --user-agent "$UA_Browser" -sSI -X GET "https://www.nicovideo.jp/watch/so23017073" --write-out "%{http_code}" --output /dev/null)

    if [[ "$result" == "curl"* ]] || [[ -z "$result" ]]; then
        echo "No"
        return
    fi
    if [[ "$result" == "400" ]]; then
        echo "No"
        return
    elif [[ "$result" == "200" ]]; then
        echo "Yes"
        return
    else
        echo "No"
    fi
}

# 生成 JSON 输出
declare -A results

results["DMM TV"]=$(MediaUnlockTest_DMMTV)
results["Abema.TV"]=$(MediaUnlockTest_AbemaTV)
results["Niconico"]=$(MediaUnlockTest_Niconico)

json_output=$(jq -n --arg dmm "${results["DMM TV"]}" --arg abema "${results["Abema.TV"]}" --arg nico "${results["Niconico"]}" \
               '{ "DMM TV": $dmm, "Abema.TV": $abema, "Niconico": $nico }')

echo "$json_output"

