TELEGRAM_TOKEN="token"
CHAT_ID="id"

TARGET_EMOJI=$'\U1F3AF'
IP_EMOJI=$'\U1F4EE'
USER_EMOJI=$'\U1F464'

if [ ${PAM_TYPE} = "open_session" ]; then
  MESSAGE=$(printf "${TARGET_EMOJI} New Login detected!\n\n${IP_EMOJI} IP: %s\n>
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d >
fi
