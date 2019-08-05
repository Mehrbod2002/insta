#!/bin/bash
string4=$(openssl rand -hex 32 | cut -c 1-4)
string8=$(openssl rand -hex 32 | cut -c 1-8)
string12=$(openssl rand -hex 32 | cut -c 1-12)
string16=$(openssl rand -hex 32 | cut -c 1-16)
device="android-$string16"
uuid=$(openssl rand -hex 32 | cut -c 1-32)
phone="$string8-$string4-$string4-$string4-$string12"
guid="$string8-$string4-$string4-$string4-$string12"
header='Connection: "close", "Accept": "*/*", "Content-type": "application/x-www-form-urlencoded; charset=UTF-8", "Cookie2": "$Version=1" "Accept-Language": "en-US", "User-Agent": "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'
var=$(curl -i -s -H "$header" https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid > /dev/null)
var2=$(echo $var | grep -o 'csrftoken=.*' | cut -d ';' -f1 | cut -d '=' -f2)
ig_sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
banner(){
printf "\033[0;35mWROTE BY AMIRHOSEIN AKHLAGHPOUR ... \nTHANKS FOR YOUR SUPPORT :)"
printf "\n"
}
start(){
if [[ $user == "" ]]; then
printf "\033[0;31mLOGIN\n"
read -p $'\033[1;33mUSERNAME:' user
fi
if [[ -e cookie.$user ]]; then
printf "\033[0;36mCookie found for your account\n" $user
default_use_cookie="Y"
read -p $'\033[0;36mUse it : [Y/n]: ' use_cookie
use_cookie="${use_cookie:-${default_use_cookie}}"
if [[ $use_cookie == *'Y'* || $use_cookie == *'y'* ]]; then
printf "\033[1;32mStart using cookie ...\n"
else
rm -rf cookie.$user
start
fi
else
read -p $'\033[1;33mPASSWORD:' pass
printf "\n"
data='{"phone_id":"'$phone'", "_csrftoken":"'$var2'", "username":"'$user'", "guid":"'$guid'", "device_id":"'$device'", "password":"'$pass'", "login_attempt_count":"0"}'
IFS=$'\n'
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
useragent='User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'
printf "\033[1;33mTring login in as $user...\n"
IFS=$'\n'
var=$(curl -c cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/accounts/login/" | grep -o "logged_in_user\|challenge\|many tries\|Please wait" | uniq ); 
if [[ $var == "challenge" ]]; then printf "\033[0;36mChallenge required\n" exit 1; elif [[ $var == "logged_in_user" ]]; then printf "\033[0;36mLogin Successful\n"; elif [[ $var == "Please wait" ]]; then echo "Please wait"; fi ;
fi
}
follow(){
read -p $'\033[1;34mPlease enter your user :' u
username_id=$(curl -L -s 'https://www.instagram.com/'$user'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
userid=$(curl -L -s 'https://www.instagram.com/'$u'' > getid && grep -o 'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
data='{"_uuid":"'$guid'", "_uid":"'$username_id'", "user_id":"'$userid'", "_csrftoken":"'$var2'"}'
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
printf "\033[1;36mtrying to follow ... $c\n"
printf "\n"
b=$(curl -s -L -b cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data"  -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani;; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/friendships/create/$userid/" | grep -o '"following": true')
if [[ $b == "" ]]; then
printf "\033[1;31mBlocked Or Have it in your Following list \n"
follow
else
printf "\033[0;36mFINIDHSED\n"
follow
fi;
}
f(){
read -p $'\033[1;34mPlease enter your fav user :' user_account
if [[ -e $user_account.followers_backup ]]; then
printf "\033[1;32mFound one file of account's followers\n"
f2
else
printf "\033[1;33mTry to make list ..."
user_id=$(curl -L -s 'https://www.instagram.com/'$user_account'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
curl -L -b cookie.$user -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/friendships/$user_id/followers/" > $user_account.followers.temp
cp $user_account.followers.temp $user_account.followers.00
count=0
while [[ true ]]; do
big_list=$(grep -o '"big_list": true' $user_account.followers.temp)
maxid=$(grep -o '"next_max_id": "[^ ]*.' $user_account.followers.temp | cut -d " " -f2 | tr -d '"' | tr -d ',')
if [[ $big_list == *'big_list": true'* ]]; then
url="https://i.instagram.com/api/v1/friendships/$user_id/followers/?rank_token=$user_id\_$guid&max_id=$maxid"
curl -L -b cookie.$user -s --user-agent 'User-agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'  -H "$header" "$url" > $user_account.followers.temp
cp $user_account.followers.temp $user_account.followers.$count
unset maxid
unset url
unset big_list
else
grep -o 'username": "[^ ]*.' $user_account.followers.* | cut -d " " -f2 | tr -d '"' | tr -d ',' > $user_account.followers_backup
tot_follow=$(wc -l $user_account.followers_backup | cut -d " " -f1)
printf "Total Followers:\n" $tot_follow
if [[ $user == $user_account ]]; then
if [[ ! -d $user/raw_followers/ ]]; then
mkdir -p $user/raw_followers/
fi
cat $user.followers.* > $user/raw_followers/backup.followers.txt
rm -rf $user.followers.*
break
else
if [[ ! -d $user_account/raw_followers/ ]]; then
mkdir -p $user_account/raw_followers/
fi
cat $user_account.followers.* > $user_account/raw_followers/backup.followers.txt
rm -rf $user_account.followers.*
break
fi
fi
let count+=1
done
fi
}
f2(){
printf "\033[1;36mRemmeber that this api can just follow public page (!private)\n"
read -p $'\033[0;37mHow many follower do you want from this user (1 hour = 60 followers allowed)' g
mkdir -p unfollow.list/unfollower.list.txt
while [[ true ]]; do
count=$g
a=1
for b in $(cat $user_account.followers_backup | sed -n "${a},${count}p"); do
userid=$(curl -L -s 'https://www.instagram.com/'$b'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
username_id=$(curl -L -s 'https://www.instagram.com/'$user'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
data='{"_uuid":"'$guid'", "_uid":"'$username_id'", "user_id":"'$userid'", "_csrftoken":"'$var2'"}'
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
printf '\033[1;36mTry to follow ... '
f=$(curl -s -L -b cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data"  -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani;qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/friendships/create/$userid/" | grep -o '"following": true')
if [[ $f == "" ]]; then
printf "\033[1;31mError (Maybe it is private , Try another one ...)\n"
else
printf "\033[1;32mOk\n"
fi
done
printf "\033[1;33mSleep for your choosen minutes\n"
sleep 3600
let count+=$g
let a+=$g
done
}
f3(){
if [[ -e unfollower.list.txt ]]; then
printf "\033[0;33mYou dont have any list , start with follow ..."
f
f2
else
printf "\033[1;36mIt is Starting ...\n"
read -p $'\033[1;35mEnter how many unfollow in your time : ' j
read -p $'\033[1;35mEnter your time : ' s
printf "\033[1;36mStart to unfollow ..."
while [[ true ]]; do
o=1
i=$j
for b in $(cat unfollower.list.txt | sed -n "${o},${j}p"); do
username_id=$(curl -L -s 'https://www.instagram.com/'$user'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
userid=$(curl -L -s 'https://www.instagram.com/'$b'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')
data='{"_uuid":"'$guid'", "_uid":"'$username_id'", "user_id":"'$userid'", "_csrftoken":"'$var2'"}'
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
printf '\033[1;32mtry to unfollow $num ... '
l=$(curl -s -L -b cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/friendships/destroy/$userid/" | grep -o '"following": false')
if [[ $l == "" ]]; then
printf "\033[1;31mError (have problem ro unfollow do it without bot)\n"
else
printf "\033[1;32mOk\n"
fi
done
let o+=$j
let i+=$j
done
fi
}
menu(){
printf "\033[1;32m1: FOLLOW OF CELEB'S FOLLOWER \n"
printf "\033[1;32m2: UNFOLLOW OF CELEB'S FOLLOWER\n"
read -p $'\033[0;32mplease enter of your colums : ' a
if [[ $a -eq 1 ]]; then
start
f
f2
elif [[ $a -eq 2 ]]; then
start
f3
else
printf "\033[0;33mWrong choice\n"
menu
fi
}
clear
banner
menu
