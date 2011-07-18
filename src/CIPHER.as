
import updater.UpdateManager;
import mx.managers.PopUpManager;
import mx.collections.ArrayCollection;
import mx.events.CloseEvent;
import mx.controls.Alert;

private var _sqlConn:SQLConnection;
private var _dbfilepath:String;

private var _datas:ArrayCollection = new ArrayCollection();
[Bindable]
public function set datas(datas:ArrayCollection):void { _datas = datas; }
public function get datas():ArrayCollection { return _datas; }

/* Application作成完了時 */
protected function onApplicationCompleted():void { 
	//new UpdateManager();
	login();
}

/* ログイン */
private function login():void {
	var login:Login = Login(PopUpManager.createPopUp(this, Login, true));
	PopUpManager.centerPopUp(login);
	login.init(init);
}

/* 初期化 */
private function init(dbfile:String, password:ByteArray):Boolean {
	if (!password) {
		stage.nativeWindow.close();
		return false;
	}
	visible = true;
	_dbfilepath = dbfile;
	return startupDB(dbfile, password);
}

/* データの初期化 */
private function initData():void {
	selectAllData();
}

/* 詳細表示 */
private function showDetail():void {
	if (grid == null || grid.selectedItem == null) {
		clearDetail();
		return;
	}
	txtTitle.text = grid.selectedItem["title"];
	lblId.text = grid.selectedItem["id"];
	txtAccount.text = grid.selectedItem["account"];
	txtPassword.text = grid.selectedItem["password"];
	txtUrl.text = grid.selectedItem["url"];
	txtTag.text = grid.selectedItem["tag"];
	txtComment.text = grid.selectedItem["comment"];
}

/* 詳細情報をクリアする */
private function clearDetail():void {
	txtTitle.text = "";
	lblId.text = "";
	txtAccount.text = "";
	txtPassword.text = "";
	txtUrl.text = "";
	txtTag.text = "";
	txtComment.text = "";
}

/* 全てのデータを表示 */
private function selectAllData():void {
	var statement:SQLStatement = new SQLStatement();
	statement.sqlConnection = _sqlConn;
	statement.text = "SELECT * FROM data";
	statement.addEventListener(SQLEvent.RESULT, onSelectAllData);
	statement.addEventListener(SQLErrorEvent.ERROR, onSQLError);
	statement.execute();
}

/* 全てのデータの表示完了時 */
private function onSelectAllData(event:SQLEvent):void {
	var work:ArrayCollection = new ArrayCollection(event.target.getResult().data);
	datas = work;
	_datas.refresh();
}

private function onSQLError(event:SQLErrorEvent):void {
	Alert.show("DBに保存できませんでした。" + event.target);
}

private function updateData():void {
	var statement:SQLStatement = new SQLStatement();
	statement.sqlConnection = _sqlConn;
	statement.text = "UPDATE data SET title=:title, account=:account, password=:password, url=:url, comment=:comment, tag=:tag"
	+ " WHERE id=:id";
	statement.parameters[":title"] = txtTitle.text;
	statement.parameters[":account"] = txtAccount.text;
	statement.parameters[":password"] = txtPassword.text;
	statement.parameters[":url"] = txtUrl.text;
	statement.parameters[":tag"] = txtTag.text;
	statement.parameters[":comment"] = txtComment.text;
	statement.parameters[":id"] = lblId.text;

	statement.addEventListener(SQLEvent.RESULT, onUpdateRefresh);
	statement.addEventListener(SQLErrorEvent.ERROR, onSQLError);
	statement.execute();
	statement = null;
}

private function onUpdateRefresh(event:SQLEvent):void {
	selectAllData();
	grid.selectedItem = getItem(lblId.text);
	showDetail();
	filter();
}

private function getItem(id:String):Object {
	for each (var data:Object in datas) {
		if (data["id"] == id) {
			return data;
		}
	} 
	return null;	
}

/* 新規追加 */
private function addData():void {
	var statement:SQLStatement = new SQLStatement();
	statement.sqlConnection = _sqlConn;
	statement.text = "INSERT INTO data (title, account, password, url, comment, tag) "
	+ "VALUES (:title, :account, :password, :url, :comment, :tag)";
	if (lblId.text != "") {
		statement.parameters[":title"] = "";
		statement.parameters[":account"] = "";
		statement.parameters[":password"] = "";
		statement.parameters[":url"] = "";
		statement.parameters[":tag"] = "";
		statement.parameters[":comment"] = "";
	} else {
		statement.parameters[":title"] = txtTitle.text;
		statement.parameters[":account"] = txtAccount.text;
		statement.parameters[":password"] = txtPassword.text;
		statement.parameters[":url"] = txtUrl.text;
		statement.parameters[":tag"] = txtTag.text;
		statement.parameters[":comment"] = txtComment.text;
	}

	statement.addEventListener(SQLEvent.RESULT, onAddRefresh);
	statement.addEventListener(SQLErrorEvent.ERROR, onSQLError);
	statement.execute();
}

private function onAddRefresh(event:SQLEvent):void {
	selectAllData();
	grid.selectedItem = datas.getItemAt(datas.length - 1);
	showDetail();
}

private function deleteData():void {
	Alert.show("削除してよろしいですか？", grid.selectedItem["title"], Alert.YES|Alert.NO, null, 
	function (event:CloseEvent):void {
		if (event.detail == Alert.YES) {
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = _sqlConn;
			statement.text = "DELETE FROM data"
			+ " WHERE id=:id";
			statement.parameters[":id"] = lblId.text;

			statement.addEventListener(SQLEvent.RESULT, onDeleteRefresh);
			statement.addEventListener(SQLErrorEvent.ERROR, onSQLError);
			statement.execute();
			clearDetail();
		}
	}
	);
}

private function onDeleteRefresh(event:SQLEvent):void {
	selectAllData();
}

/* DBの起動 */
private function startupDB(dbfile:String, password:ByteArray):Boolean {
	var file:File = new File(dbfile);
	_sqlConn = new SQLConnection();
	_sqlConn.addEventListener(SQLEvent.OPEN, createDBTable);
	_sqlConn.addEventListener(SQLErrorEvent.ERROR, onSQLiteOpenError);
	try {
		_sqlConn.open(file, SQLMode.CREATE, false, 1024, password);
		return true;
	} catch(e:SQLError) {
		if (e.errorID == 3138){
			Alert.show("パスワードが違うためDBをOpenできませんでした。");
		} else if (e.errorID == 3125) {
			Alert.show("DBファイルが存在しませんでした。");
		} else {
			Alert.show("予期せぬエラー" + e);
		}
	}
	return false;
}

/* SQLite接続失敗 */
private function onSQLiteOpenError(event:SQLErrorEvent):void {
	trace("接続失敗:" + event);
}

/* DB用テーブル作成 */
private function createDBTable(event:SQLEvent):void {
	var statement:SQLStatement = new SQLStatement();
	statement.sqlConnection = _sqlConn;
	statement.text = "CREATE TABLE IF NOT EXISTS data("
	+ "id INTEGER PRIMARY KEY,"
	+ "title TEXT,"
	+ "account TEXT,"
	+ "password TEXT,"
	+ "url TEXT,"
	+ "comment TEXT,"
	+ "tag TEXT)";
	statement.execute();
	initData();
}

/* フィルタ */
private var filterString:String;
public function filter():void {
	filterString = txtFilter.text.toLowerCase();
	datas.filterFunction = doFilter;
	datas.refresh();
}

public function doFilter(mydata:Object):Boolean {
	var v:String = mydata["title"].toLowerCase();
	if (v.match(filterString)) {
		return true;
	} else {
		if (mydata["tag"].toLowerCase().match(filterString)) {
			return true;
		}
		return false;
	}
}

/* パスワードの変更 */
private function changePassword():void {
	var window:ChangePassword = ChangePassword(
	PopUpManager.createPopUp(this, ChangePassword, true));
	window.init(_sqlConn, _dbfilepath);
	PopUpManager.centerPopUp(window);
}
