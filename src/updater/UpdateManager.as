package updater{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.core.UIComponent;
	import mx.controls.Alert;
	
	public class UpdateManager extends UIComponent {
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI;
		
		public function get applicationUpdater():ApplicationUpdaterUI{
			return appUpdater;				
		}	
		
		public function UpdateManager() {
			super();
			appUpdater.configurationFile = new File("app:/updateConfig.xml");
			appUpdater.addEventListener(ErrorEvent.ERROR, onError);
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onInitialize);
			appUpdater.initialize();
		}
		
		private function onError(event:ErrorEvent):void {
			Alert.show("Application Update Error " + event);
		}
		
		private function onInitialize(event:UpdateEvent):void {
			appUpdater.checkNow();
		}		
	}
}