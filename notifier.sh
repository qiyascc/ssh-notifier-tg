TELEGRAM_TOKEN="token"
CHAT_ID="id"

TARGET_EMOJI=$'\U1F3AF'
IP_EMOJI=$'\U1F4EE'
USER_EMOJI=$'\U1F464'

if [ ${PAM_TYPE} = "open_session" ]; then
  MESSAGE=$(printf "**${TARGET_EMOJI} New Login detected!**\n\n${IP_EMOJI} **IP:** %s\n${USER_EMOJI} **User:** %s\n⌨ **Login Type:** %s" "$PAM_RHOST" "$PAM_USER" "$PAM_SERVICE")

  CALLBACK_DATA="stop-$PAM_USER"
  KEYBOARD="{\"inline_keyboard\":[[{\"text\":\"Stop Session\",\"callback_data\":\"$CALLBACK_DATA\"}]]}"

  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$MESSAGE&parse_mode=Markdown&reply_markup=$KEYBOARD"
fi

