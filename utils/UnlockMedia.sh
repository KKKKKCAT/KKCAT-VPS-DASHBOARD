#!/bin/bash

# 引入参数
curlArgs="-4 -s --max-time 10"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.64"
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)"
Media_Cookie=$(curl -s --retry 3 --max-time 10 "https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/cookies")

# Function to test DAZN
test_dazn() {
    local tmpresult=$(curl -sS --max-time 10 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' "https://startup.core.indazn.com/misl/v5/Startup")
    local isAllowed=$(echo $tmpresult | grep -o '"isAllowed":true')
    local result=$(echo $tmpresult | grep -oP '(?<="GeolocatedCountry":")[^"]*')

    if [[ "$isAllowed" == '"isAllowed":true' ]]; then
        local CountryCode=$(echo $result | tr [:lower:] [:upper:])
        echo "Dazn: Yes(${CountryCode})"
    else
        echo "Dazn: No"
    fi
}

# Function to test Disney+
test_disneyplus() {
    # Step 1: Get Pre-Assertion token
    local PreAssertion=$(curl --user-agent "$UA_Browser" -s -X POST "https://disney.api.edge.bamgrid.com/devices" \
        -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" \
        -H "content-type: application/json; charset=UTF-8" \
        -d '{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}')
    
    if [[ "$PreAssertion" == "curl"* ]]; then
        echo "Disney+: Failed (Network Connection[1])"
        return
    fi
    
    # Extract assertion token
    local assertion=$(echo $PreAssertion | grep -oP '(?<="assertion":")[^"]*')
    if [[ -z "$assertion" ]]; then
        echo "Disney+: Failed (No assertion token found)"
        return
    fi
    
    # Step 2: Prepare disneycookie using the assertion token
    local PreDisneyCookie=$(echo "$Media_Cookie" | sed -n '1p')
    local disneycookie=$(echo $PreDisneyCookie | sed "s/DISNEYASSERTION/${assertion}/g")

    # Step 3: Exchange assertion token for access token
    local TokenContent=$(curl --user-agent "$UA_Browser" -s -X POST "https://disney.api.edge.bamgrid.com/token" \
        -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" \
        -d "$disneycookie")
    
    if [[ "$TokenContent" == "curl"* ]]; then
        echo "Disney+: Failed (Network Connection[2])"
        return
    fi

    # Check if location is banned or token request failed
    local isBanned=$(echo $TokenContent | grep 'forbidden-location')
    local is403=$(echo $TokenContent | grep '403 ERROR')

    if [[ -n "$isBanned" ]] || [[ -n "$is403" ]]; then
        echo "Disney+: No(Banned)"
        return
    fi

    # Extract refresh token
    local refreshToken=$(echo $TokenContent | grep -oP '(?<="refresh_token":")[^"]*')
    if [[ -z "$refreshToken" ]]; then
        echo "Disney+: Failed (No refresh token found)"
        return
    fi
    
    # Step 4: Validate Disney+ region support
    local fakecontent=$(echo "$Media_Cookie" | sed -n '8p')
    local disneycontent=$(echo $fakecontent | sed "s/ILOVEDISNEY/${refreshToken}/g")
    local tmpresult=$(curl --user-agent "$UA_Browser" -X POST -sSL --max-time 10 "https://disney.api.edge.bamgrid.com/graph/v1/device/graphql" \
        -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" \
        -d "$disneycontent")
    
    if [[ "$tmpresult" == "curl"* ]]; then
        echo "Disney+: Failed (Network Connection[3])"
        return
    fi

    # Final validation check
    local region=$(echo $tmpresult | grep -oP '(?<="countryCode":")[^"]*')
    local inSupportedLocation=$(echo $tmpresult | grep -oP '(?<="inSupportedLocation":)[^,]*')

    if [[ "$inSupportedLocation" == "true" ]]; then
        echo "Disney+: Yes($region)"
    else
        echo "Disney+: No"
    fi
}

# Function to test Netflix
test_netflix() {
    local result1=$(curl -fsLI -X GET --user-agent "$UA_Browser" --max-time 10 --tlsv1.3 "https://www.netflix.com/title/81280792" -w "%{http_code}" -o /dev/null)
    local result2=$(curl -fsLI -X GET --user-agent "$UA_Browser" --max-time 10 --tlsv1.3 "https://www.netflix.com/title/70143836" -w "%{http_code}" -o /dev/null)
    local region=$(curl -sI -X GET --user-agent "$UA_Browser" --max-time 10 "https://www.netflix.com/login" | grep -oP '(?<=location: https://www.netflix.com/)[^/]*' | cut -d '-' -f1 | tr [:lower:] [:upper:])

    if [[ "$result1" == "404" ]] && [[ "$result2" == "404" ]]; then
        echo "Netflix: Originals Only (Region: ${region})"
    elif [[ "$result1" == "200" ]] || [[ "$result2" == "200" ]]; then
        echo "Netflix: Yes(${region})"
    else
        echo "Netflix: No"
    fi
}

# Function to test YouTube Premium
test_youtube_premium() {
    local tmpresult=$(curl -s --user-agent "$UA_Browser" --max-time 10 -H "Accept-Language: en" "https://www.youtube.com/premium")
    local region=$(echo $tmpresult | grep -oP '(?<="countryCode":")[^"]*')

    if [[ "$tmpresult" == *"purchaseButtonOverride"* ]] || [[ "$tmpresult" == *"Start trial"* ]]; then
        if [[ -n "$region" ]]; then
            echo "YouTube Premium: Yes(${region})"
        else
            echo "YouTube Premium: Yes"
        fi
    else
        echo "YouTube Premium: No"
    fi
}

# Function to test TikTok
test_tiktok() {
    local result=$(curl -s --user-agent "$UA_Browser" -fsSL --max-time 10 -w "%{url_effective}" "https://www.tiktok.com/")
    local result1=$(curl -s --user-agent "$UA_Browser" -fsSL --max-time 10 -X POST "https://www.tiktok.com/passport/web/store_region/")
    local region=$(echo "$result1" | grep -oP '(?<="store_region":")[^"]*')

    if [[ "$result" == *"/explore"* ]]; then
        echo "Tiktok: Yes(${region^^})"
    else
        echo "Tiktok: No(${region^^})"
    fi
}

# Function to test Bahamut Anime
MediaUnlockTest_BahamutAnime() {
    local tmpdeviceid=$(curl $curlArgs --user-agent "$UA_Browser" -fsSL "https://ani.gamer.com.tw/ajax/getdeviceid.php" --cookie-jar bahamut_cookie.txt)
    
    if [[ "$tmpdeviceid" == "curl"* ]] || [[ -z "$tmpdeviceid" ]]; then
        echo "Bahamut Anime: No (Failed to get device ID)"
        rm -f bahamut_cookie.txt
        return
    fi
    
    local tempdeviceid=$(echo "$tmpdeviceid" | jq -r '.deviceid // empty')

    local tmpresult=$(curl $curlArgs --user-agent "$UA_Browser" -fsSL "https://ani.gamer.com.tw/ajax/token.php?adID=89422&sn=38832&device=${tempdeviceid}" -b bahamut_cookie.txt)
    local tmpresult2=$(curl $curlArgs --user-agent "$UA_Browser" -fsSL "https://ani.gamer.com.tw/ajax/token.php?adID=89422&sn=37783&device=${tempdeviceid}" -b bahamut_cookie.txt)
    
    rm -f bahamut_cookie.txt

    if [[ "$tmpresult" == "curl"* ]] || [[ "$tmpresult2" == "curl"* ]]; then
        echo "Bahamut Anime: No (Failed to fetch region info)"
        return
    fi

    local result=$(echo "$tmpresult" | jq '.animeSn // empty')
    local result2=$(echo "$tmpresult2" | jq '.animeSn // empty')

    if [ -n "$result" ] && [ -n "$result2" ]; then
        echo "Bahamut Anime: Yes(TW)"
    elif [ -n "$result2" ]; then
        echo "Bahamut Anime: Yes(HK/MO)"
    else
        echo "Bahamut Anime: No"
    fi
}

# Function to test Bilibili Anime
MediaUnlockTest_BilibiliAnimeNew() {
    local tmp=$(curl $curlArgs --user-agent "$UA_Browser" -fsSL "https://api.bilibili.com/x/web-interface/zone")
    
    if [[ $? -ne 0 ]]; then
        echo "Bilibili Anime: Failed (Network Connection)"
        return
    fi

    local country_code=$(echo "$tmp" | jq -r '.data.country_code // empty')

    if [[ "$country_code" == "86" ]]; then
        echo "Bilibili Anime: Yes(CN)"
    elif [[ "$country_code" == "886" ]]; then
        echo "Bilibili Anime: Yes(TW)"
    elif [[ "$country_code" == "852" ]]; then
        echo "Bilibili Anime: Yes(HK)"
    elif [[ "$country_code" == "853" ]]; then
        echo "Bilibili Anime: Yes(MO)"
    else
        local country=$(echo "$tmp" | jq -r '.data.country // empty')
        echo "Bilibili Anime: No($country)"
    fi
}

# Run all tests
test_dazn
test_disneyplus
test_netflix
test_youtube_premium
test_tiktok
MediaUnlockTest_BahamutAnime
MediaUnlockTest_BilibiliAnimeNew
