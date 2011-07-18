import mx.managers.PopUpManager;
import mx.controls.Alert;

private var _sqlConnection:SQLConnection;

public function init(sqlConnection:SQLConnection, dbFilePath:String):void {
	_sqlConnection = sqlConnection;
	lblDbfile.text = dbFilePath;
}

private function ok():void {
	var bytes:ByteArray = new ByteArray();
	bytes.writeUTFBytes(txtPassword.text);
	
	if (!Store.checkPasswordLength(bytes)) {
		return;
	}
	
	if (chkSave.selected) {
		Store.passwordSave(bytes);
	} else {
		Store.passwordSave(new ByteArray());
	}
	_sqlConnection.addEventListener(SQLEvent.REENCRYPT, onSuccess);
	_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onError);
	_sqlConnection.reencrypt(bytes, null);
}

private function cancel():void {
	PopUpManager.removePopUp(this);
}

private function onSuccess(event:SQLEvent):void {
	removeListener();
	Alert.show("更新が完了しました");
	PopUpManager.removePopUp(this);

}

private function onError(event:SQLEvent):void {
	removeListener();
	Alert.show("更新に失敗しました");
}

private function removeListener():void {
	_sqlConnection.removeEventListener(SQLEvent.REENCRYPT, onSuccess);
	_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onError);
}

