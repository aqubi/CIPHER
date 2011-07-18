/**
* @author ogawahideko
*/
package  {
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import flash.net.SharedObject;
	import flash.data.EncryptedLocalStore;
	
	public class Store {
		private static const OS_PASSWORD_PREFIX:String = "cipher-password";
		private static const SHARED_FILE:String = "cipher";

		public static function checkPasswordLength(bytes:ByteArray):Boolean {
			if (bytes.length != 16) {
				Alert.show("パスワードは16バイト必要です。");
				return false;
			}
			return true;
		}

		/* dbFileをSharedObjectに保存する */
		public static function dbFilePathSave(dbFilePath:String):void {
			var sharedObject:SharedObject = SharedObject.getLocal(SHARED_FILE);
			sharedObject.data.dbFile=dbFilePath;
			sharedObject.flush();
		}
		
		public static function dbFilePathLoad():String {
			var sharedObject:SharedObject = SharedObject.getLocal(SHARED_FILE);
			return sharedObject.data.dbFile;
		}

		/*Passwordの保存 */
		public static function passwordSave(password:ByteArray):void {
			try {
				EncryptedLocalStore.setItem(OS_PASSWORD_PREFIX, password);
			} catch(e:Error) {
			}
		}

		/* Passwordのload */
		public static function passwordLoad():ByteArray {
			//try {
				var storedValue:ByteArray = EncryptedLocalStore.getItem(OS_PASSWORD_PREFIX);
				return storedValue;
			//} catch(e:Error) {
			//	Alert.show("パスワードが保存できませんでした : " + e);
			//	trace(e);
			//}
			//return new ByteArray();
		}

	}
}