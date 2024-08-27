#!/bin/bash

# 引入參數
curlArgs="$useNIC $usePROXY $xForward $resolve $dns --max-time 10"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.64"

# 檢測 KKTV
function MediaUnlockTest_KKTV() {
    local tmpresult=$(curl $curlArgs -s --max-time 10 "https://api.kktv.me/v3/ipcheck")
    local result=$(echo "$tmpresult" | jq -r '.data.country // empty')

    if [[ "$result" == "TW" ]]; then
        echo "KKTV: Yes"
    else
        echo "KKTV: No"
    fi
}

# 檢測 LiTV
function MediaUnlockTest_LiTV() {
    local tmpresult=$(curl $curlArgs -sS --max-time 10 -X POST 'https://www.litv.tv/api/get-urls-no-auth' -H 'content-type: application/json' -d '{"AssetId":"iNEWS","MediaType":"channel","puid":"b0b59472-72eb-4e06-b0b1-591716e4f9a4"}')
    local result=$(echo "$tmpresult" | jq -r '.error.code // empty')

    if [[ "$result" == "42000087" ]]; then
        echo "LiTV: No"
    elif [[ "$result" == "42000075" ]]; then
        echo "LiTV: Yes"
    else
        echo "LiTV: Failed"
    fi
}

# 檢測 MyVideo
function MediaUnlockTest_MyVideo() {
    local tmpresult=$(curl $curlArgs -sSL -o /dev/null --max-time 10 -w '%{url_effective}' "https://www.myvideo.net.tw/login.do")
    local result=$(echo "$tmpresult" | grep 'serviceAreaBlock')

    if [ -n "$result" ]; then
        echo "MyVideo: No"
    else
        echo "MyVideo: Yes"
    fi
}

# 檢測 LineTV.TW
function MediaUnlockTest_LineTV_TW() {
    local tmpresult=$(curl $curlArgs -s --max-time 10 "https://www.linetv.tw/api/part/11829/eps/1/part?chocomemberId=&appId=062097f1b1f34e11e7f82aag22000aee")
    local result=$(echo "$tmpresult" | jq -r '.countryCode // empty')

    if [[ "$result" == "228" ]]; then
        echo "LineTV.TW: Yes"
    else
        echo "LineTV.TW: No"
    fi
}

# 檢測 Hami Video
function MediaUnlockTest_HamiVideo() {
    local tmpresult=$(curl $curlArgs --user-agent "${UA_Browser}" -s --max-time 10 "https://hamivideo.hinet.net/api/play.do?id=OTT_VOD_0000249064&freeProduct=1")
    local checkfailed=$(echo "$tmpresult" | jq -r '.code // empty')

    if [[ "$checkfailed" == "06001-106" ]]; then
        echo "Hami Video: No"
    elif [[ "$checkfailed" == "06001-107" ]]; then
        echo "Hami Video: Yes"
    else
        echo "Hami Video: Failed"
    fi
}

# 檢測 CatchPlay+
function MediaUnlockTest_Catchplay() {
    local tmpresult=$(curl $curlArgs -s --max-time 10 "https://sunapi.catchplay.com/geo" -H "authorization: Basic NTQ3MzM0NDgtYTU3Yi00MjU2LWE4MTEtMzdlYzNkNjJmM2E0Ok90QzR3elJRR2hLQ01sSDc2VEoy")
    local result=$(echo "$tmpresult" | jq -r '.code // empty')
    local region=$(echo "$tmpresult" | jq -r '.isoCode // empty')

    if [[ "$result" == "0" ]]; then
        echo "CatchPlay+: Yes (Region: ${region})"
    elif [[ "$result" == "100016" ]]; then
        echo "CatchPlay+: No"
    else
        echo "CatchPlay+: Failed"
    fi
}

# 檢測 Friday Video
function MediaUnlockTest_FridayVideo() {
    local tmpresult=$(curl $curlArgs -sSL --max-time 10 --user-agent "${UA_Browser}" 'https://video.friday.tw/api2/streaming/get?streamingId=122581&streamingType=2&contentType=4&contentId=1&clientId=')
    local result=$(echo "$tmpresult" | jq -r '.code // empty')

    if [[ "$result" == "1006" ]]; then
        echo "Friday Video: No"
    elif [[ "$result" == "0000" ]]; then
        echo "Friday Video: Yes"
    else
        echo "Friday Video: Failed"
    fi
}

# 生成 JSON 输出
declare -A results

results["KKTV"]=$(MediaUnlockTest_KKTV | awk '{print $2}')
results["LiTV"]=$(MediaUnlockTest_LiTV | awk '{print $2}')
results["MyVideo"]=$(MediaUnlockTest_MyVideo | awk '{print $2}')
results["LineTV.TW"]=$(MediaUnlockTest_LineTV_TW | awk '{print $2}')
results["Hami Video"]=$(MediaUnlockTest_HamiVideo | awk '{print $3}')
results["CatchPlay+"]=$(MediaUnlockTest_Catchplay | awk '{print $2}')
results["Friday Video"]=$(MediaUnlockTest_FridayVideo | awk '{print $3}')

# 确保每个值都为 Yes/No，如果不是，则标记为 Failed
for key in "${!results[@]}"; do
    if [[ "${results[$key]}" != "Yes" && "${results[$key]}" != "No" ]]; then
        results[$key]="Failed"
    fi
done

# 生成 JSON 输出
json_output=$(jq -n --arg kktv "${results["KKTV"]}" \
                       --arg litv "${results["LiTV"]}" \
                       --arg myvideo "${results["MyVideo"]}" \
                       --arg linetv "${results["LineTV.TW"]}" \
                       --arg hamivideo "${results["Hami Video"]}" \
                       --arg catchplay "${results["CatchPlay+"]}" \
                       --arg friday "${results["Friday Video"]}" \
                       '{
                           "KKTV": $kktv,
                           "LiTV": $litv,
                           "MyVideo": $myvideo,
                           "LineTV.TW": $linetv,
                           "Hami Video": $hamivideo,
                           "CatchPlay+": $catchplay,
                           "Friday Video": $friday
                       }')

echo "$json_output"

