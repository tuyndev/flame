import 'package:flutter_flame_lib/common/observer.dart';

enum MESSAGE_OBSERVER_TYPE { OPEN_MODAL, CLOSE_MODAL, CHANGE_FILL_QUESTION }

extension MessageObserverType on MESSAGE_OBSERVER_TYPE {
  String get toValue {
    switch (this) {
      case MESSAGE_OBSERVER_TYPE.OPEN_MODAL:
        return "OPEN_MODAL";
      case MESSAGE_OBSERVER_TYPE.CLOSE_MODAL:
        return "CLOSE_MODAL";
      case MESSAGE_OBSERVER_TYPE.CHANGE_FILL_QUESTION:
        return "CHANGE_FILL_QUESTION";
    }
  }
}

class MessagesObserver extends GameObserver {
  @override
  post(MESSAGE_OBSERVER_TYPE messageType, Map<String, dynamic>? extraData) {
    lstSlave.forEach((element) {
      element.onMessage(messageType.toValue, extraData);
    });
  }
}

final messagesObserver = MessagesObserver();
