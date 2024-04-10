import UIKit

class MessageInputBarAssistance: MessageInputBar {
    
    override init(delegate: MessageInputBarDelegate) {
        super.init(delegate: delegate)
        
        exchangesButton.isHidden = true
        microButton.isHidden = true
        sendButton.setImage(kInputSendImage, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sendButtonDidTap() {
        guard let message = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !message.isEmpty else {
            return
        }
        messageTextView.text = ""
        delegate?.message(text: message)
        textViewDidChange(messageTextView)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if Date().timeIntervalSince(lastTypingDate) > kTypingMinInterval {
            self.lastTypingDate = Date()
            self.delegate?.typing(is: true)
        }
    }
    
}
