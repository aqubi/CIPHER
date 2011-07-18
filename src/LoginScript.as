import flash.data.EncryptedLocalStore;
import mx.managers.PopUpManager;

private static const DEFAULT_DB_PATH:String = "app-storage:/cipher.db";

private var _callback:Function;

public function init(callback:Function):void {
	_callback = callback;
	txtPassword.text = String(Store.passwordLoad());
	txtDbfile.text = Store.dbFilePathLoad();
	if (txtDbfile.text.length == 0) {
		txtDbfile.text = DEFAULT_DB_PATH;
	}
}


private function ok():void {
	var dbfile:String = txtDbfile.text;
	Store.dbFilePathSave(dbfile);
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
	if (_callback(txtDbfile.text, bytes)) {
		PopUpManager.removePopUp(this);
	}
}

private function cancel():void {
	PopUpManager.removePopUp(this);
	_callback(null, null);
}

private function selectFile():void {
	var file:File = File.desktopDirectory;
	function selectHandler(event:Event):void {
		txtDbfile.text = file.nativePath;
	}
    file.addEventListener(Event.SELECT,selectHandler);
    file.browseForOpen("DBファイルを選択してください。");
}

private function restoreDefault():void {
	txtDbfile.text = "app-storage:/cipher.db";
}

