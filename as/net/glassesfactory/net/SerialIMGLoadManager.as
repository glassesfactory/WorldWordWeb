/*////////////////////////////////////////////

WorldWordWeb

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/03/26

Copyright 2010 glasses factory
http://glasses-factory.net

/*////////////////////////////////////////////

package net.glassesfactory.net
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import net.glassesfactory.display.Node;
	import net.glassesfactory.events.SerialIMGLoadEvent;
	import net.glassesfactory.events.SerialNewsLoadEvent;
	import net.glassesfactory.model.NodeModel;
	import net.glassesfactory.net.AMFConnecter;
	
	public class SerialIMGLoadManager extends EventDispatcher
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		public function get stackNum():uint{ return _currentIDStack.length; } 
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function SerialIMGLoadManager( caller:Function = null )
		{
			if( caller != SerialIMGLoadManager.getInstance )
			{
				throw new Error("SerialNewsLoadManagerを直接インスタンス化は出来ません");
			}
			else if( _instance == null )
			{
				_amf = AMFConnecter.getInstance(WorldWordWeb.MORPHO_URL);
				_loadStack = [];
				_currentIDStack = [];
				_loadedAry = [];
				_resultFuncDict = new Dictionary();
				_loadCheckDict = new Dictionary();
				_modelDict = new Dictionary();
				_bmdDict = new Dictionary();
				_progressFuncDict = new Dictionary();
				_openFuncDict = new Dictionary();
				_ioErrorFuncDict = new Dictionary();
				_checkIDDict = new Dictionary();
			}
		}
		
		public static function getInstance():SerialIMGLoadManager
		{
			if( _instance == null )
			{
				_instance = new SerialIMGLoadManager( arguments.callee );
			}
			return _instance;
		}
		
		public function add( key:String, resultFunc:Function, model:NodeModel  ):void
		{
			if( key == "" ){ return; }
			if( _resultFuncDict[model.id] == undefined )
			{
				_loadStack.push( key );
				_currentIDStack.push( model.id );
				_resultFuncDict[model.id] = [];
				_checkIDDict[model.id] = model.id;
				_modelDict[model.id] = model;
			}
			_resultFuncDict[model.id].push( resultFunc );
		}
		
		
		/**
		 * 読み込みを実行
		 */
		public function load():void
		{
			if( _isLoading ){ return; }
			_isLoading = true;
			var key:String = _loadStack[0];
			var id:int = _currentIDStack[0];
			var model:NodeModel = _modelDict[id];
			var size:Number = model.size;
			if( key == null ){ return; }
			
			//もう読み込んでいる場合
			if( _loadCheckDict[key] != undefined )
			{
				trace("same key");
				if( _loadCheckDict[key] )
				{
					_doCompleteFunc(key, id);
					_killStackHead(); //ロードスタックの先頭を削除
					_checkNextStack();	//次のタスクが無いか見に行く
					return;
				}
			}
			
			if( _loader == null )
			{
				_loader = new Loader();
			}
			
			_loadCheckDict[key] = false;
			//_loader.load( new URLRequest( _loadStack[0]), new LoaderContext( true ));
			_nowLoadKey = key;
			_amf.call( "imageutil.loadThumb", _loadCompleteHandler, key, size );
		}
		
		
		/**
		 * 読み込みを停止
		 */
		public function stop( key:String ):void
		{
			var find:Boolean = false;
			for( var i:int = 0; i < _loadStack.length; i++ )
			{
				var _checkKey:String = _loadStack[i];
				if( _checkKey != key ){ continue; }
				else
				{
					find = true;
					_loadCheckDict[key] = null;
					delete _loadCheckDict[key];
					_resultFuncDict[key] = null;
					delete _resultFuncDict[key];
					
					var stack:Array = _loadStack.slice();
					var killStack:Array = stack.splice(i);
					killStack.shift();
					_loadStack = stack.concat( killStack );
					return;
				}
			}
		}
		
		
		/**
		 * 全部止める 
		 */		
		public function allStop():void
		{
			_loaderRemoveListener();
			for( var i:int = 0; i < _loadStack.length; i++ )
			{
				var url:String = _loadStack[i];
				_loadStack[i] = null;
				stop( url );
			}
			_loadStack = [];
		}
		
		
		/**
		 *何もかも消す 
		 */		
		public function allKill():void
		{
			allStop();
			for ( var i:int = 0; i < _loadedAry.length; i++ )
			{
				var model:Object = _modelDict[_loadedAry[i]] as Object;
				if( model != null ){ model = null }
			}
			_loadedAry = [];
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		/**
		 * 読み込み完了
		 */
		private function _loadCompleteHandler( result:Object ):void
		{
			if( result is ByteArray )
			{
				_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _imgCompleteHandler );
				_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, _loadProgressHandler );
				_loader.contentLoaderInfo.addEventListener( Event.OPEN, _loadOpenHandler );
				_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, _loadIOErrorHandler );
				_loader.loadBytes( result as ByteArray );
			}
			else
			{
				_imgCompleteHandler( new Event( Event.COMPLETE ));
			}
		}
		
		
		private function _imgCompleteHandler( e:Event ):void
		{
			var key:String = _loadStack[0];
			var id:int = _currentIDStack[0];
			var bmd:BitmapData;
			if( _loader.content )
			{
				bmd = Bitmap( _loader.content ).bitmapData;
			}
			else{
				bmd = new noImage();
			}
			_bmdDict[key] = bmd;
			_loadCheckDict[key] = true;
			var model:NodeModel = _modelDict[id];
			//model.img = bmd.clone();
			_loadedAry.push( key );
			_doCompleteFunc( key, id );
			_killStackHead();
			_checkNextStack();
		}
		
		private function _doCompleteFunc( key:String, id:int ):void
		{
			if( _resultFuncDict[id] != null )
			{
				var model:NodeModel = _modelDict[id];
				model.img = _bmdDict[key].clone();
				var complete:SerialIMGLoadEvent = new SerialIMGLoadEvent( SerialIMGLoadEvent.COMPLETE );
				complete.model = model;
				complete.key = key;
				complete.id = model.id;
				var i:int;
				var len:uint = _resultFuncDict[id].length;
				
				for( i = 0; i < len; i++ )
				{
					var compFunc:Function = _resultFuncDict[id][i];
					//compFunc( complete );
					compFunc( model );
				}
			}
			_killFunc( id );
		}
		
		private function _loadProgressHandler( e:ProgressEvent ):void
		{
			var url:String = _loadStack[0];
			var id:uint = _checkIDDict[url];
			
			var progress:SerialIMGLoadEvent = new SerialIMGLoadEvent( SerialIMGLoadEvent.PROGRESS );
			progress.bytesTotal = e.bytesTotal;
			progress.bytesLoaded = e.bytesLoaded;
			progress.percent = e.bytesLoaded / e.bytesTotal * 100;
			progress.id = id;
			if( _progressFuncDict[url] != null )
			{
				var len:uint = _progressFuncDict[url].length;
				for( var i:int = 0; i < len; i++ )
				{
					var progFunc:Function = _progressFuncDict[url][i];
					progFunc( progress );
				}
			}
		}
		
		
		private function _loadOpenHandler( e:Event ):void
		{
			var url:String  = _loadStack[0];
			var id:uint = _checkIDDict[url];
			
			var open:SerialIMGLoadEvent = new SerialIMGLoadEvent( SerialIMGLoadEvent.OPEN );
			open.model.imgURL = url;
			open.id = id;
			
			if( _openFuncDict[url] != null )
			{
				var len:uint = _openFuncDict[url].length;
				for( var i:int = 0; i < len; i++ )
				{
					var openFunc:Function = _openFuncDict[url][i];
					openFunc( open );
				}
			}
		}
		
		/**
		 * 読み込み失敗
		 */
		private function _loadIOErrorHandler( e:IOErrorEvent ):void
		{
			var url:String  = _loadStack[0];
			var id:uint = _checkIDDict[url];
			var error:SerialIMGLoadEvent = new SerialIMGLoadEvent( SerialIMGLoadEvent.ERROR );
			error.text = e.text;
			error.id = id;
			
			if( _ioErrorFuncDict[url] != null )
			{
				var len:uint = _ioErrorFuncDict[url].length;
				for( var i:int = 0; i < len; i++ )
				{
					var errorFunc:Function = _ioErrorFuncDict[url][i];
					errorFunc( error );
				}
			}
			stop( url ); 
		}
		
		
		
		private function _killFunc( id:int ):void
		{
			if( _resultFuncDict[id] != null )
			{
				_resultFuncDict[id] = null;
				delete _resultFuncDict[id];
			}
		}
		
		
		/**
		 * スタックの先頭を削除
		 */
		private function _killStackHead():void
		{
			_loadStack.shift();
			_currentIDStack.shift();
			_nowLoadKey = null;
		}
		
		
		/**
		 * 次のタスクを確認
		 */ 
		private function _checkNextStack():void
		{
			_isLoading = false;
			//if( _loadStack.length != 0 )
			if( _currentIDStack.length != 0 )
			{
				load();
			}
			else
			{
				//タスクがなくなったことを通知
				_loaderRemoveListener();
				_instance.dispatchEvent( new SerialIMGLoadEvent( SerialIMGLoadEvent.STACK_COMPLETE ));
			}
		}
		
		
		private function _loaderRemoveListener():void
		{
			if( _loader != null )
			{
				_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, _loadCompleteHandler );
				_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, _loadProgressHandler );
				_loader.contentLoaderInfo.removeEventListener( Event.OPEN, _loadOpenHandler );
				_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, _loadIOErrorHandler );
				_loader = null;
			}
		}
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private static var _instance:SerialIMGLoadManager;
		private var _amf:AMFConnecter;
		
		private var _isLoading:Boolean = false;
		private var _nowLoadKey:String;
		private var _loader:Loader;
		
		private var _loadStack:Array;
		private var _currentIDStack:Array;
		private var _loadedAry:Array;
		private var _resultFuncDict:Dictionary;
		private var _modelDict:Dictionary;
		private var _bmdDict:Dictionary;
		private var _loadCheckDict:Dictionary;
		private var _checkIDDict:Dictionary;
		private var _progressFuncDict:Dictionary;
		private var _openFuncDict:Dictionary;
		private var _ioErrorFuncDict:Dictionary;
		
	}
}