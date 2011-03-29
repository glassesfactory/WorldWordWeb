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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import net.glassesfactory.events.SerialNewsLoadEvent;
	import net.glassesfactory.model.NodeModel;
	import net.glassesfactory.net.AMFConnecter;
	
	public class SerialNewsLoadManager extends EventDispatcher
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function SerialNewsLoadManager( caller:Function = null )
		{
			if( caller != SerialNewsLoadManager.getInstance )
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
				_checkIDDict = new Dictionary();
				_sizeDict = new Dictionary();
			}
		}
		
		public static function getInstance():SerialNewsLoadManager
		{
			if( _instance == null )
			{
				_instance = new SerialNewsLoadManager( arguments.callee );
			}
			return _instance;
		}
		
		public function add( key:String, resultFunc:Function, id:int, size:Number = 140 ):void
		{
			if( key == "" ){ return; }
			if( _resultFuncDict[id] == undefined )
			{
				_loadStack.push( key );
				_currentIDStack.push( id );
				_resultFuncDict[id] = [];
				_checkIDDict[key] = id;
				_sizeDict[key] = size;
			}
			_resultFuncDict[id].push( resultFunc );
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
			if( key == null ){ return; }
			
			//もう読み込んでいる場合
			/*
			if( _loadCheckDict[key] != undefined )
			{
				trace("same key");
				if( _loadCheckDict[key] )
				{
					_doCompleteFunc(key,id);
					_killStackHead(); //ロードスタックの先頭を削除
					_checkNextStack();	//次のタスクが無いか見に行く
					return;
				}
			}
			*/
			
			_loadCheckDict[key] = false;
			_nowLoadKey = key;
			_amf.call( "newsloader.load", _loadCompleteHandler, key );
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
			//_loaderRemoveListener();
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
			var key:String = _loadStack[0];
			_loadCheckDict[key] = true;
			var id:int = _currentIDStack[0];
			trace("make model", id );
			var model:NodeModel = new NodeModel( id, _sizeDict[key], result.text, result.url);
			//手動やで
			model.keywords = [ result.one, result.two, result.three ];
			model.key = result.keyword;
			model.imgURL = result.imgURL;
			_modelDict[id] = model;
			_loadedAry.push( key );
			_doCompleteFunc( key,id );
			_killStackHead();
			_checkNextStack();
		}
		
		private function _doCompleteFunc( key:String, id:int ):void
		{
			if( _resultFuncDict[id] != null )
			{
				var model:NodeModel = _modelDict[id];
				
				var complete:SerialNewsLoadEvent = new SerialNewsLoadEvent( SerialNewsLoadEvent.COMPLETE );
				complete.model = model;
				complete.key = key;
				complete.id = model.id;
				var i:int;
				var len:uint = _resultFuncDict[id].length;
				
				for( i = 0; i < len; i++ )
				{
					var compFunc:Function = _resultFuncDict[id][i];
					//compFunc( complete );
					trace("comp",id);
					compFunc( model );
				}
			}
			_killFunc( id );
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
			if( _loadStack.length != 0 )
			{
				load();
			}
			else
			{
				//タスクがなくなったことを通知
				_instance.dispatchEvent( new SerialNewsLoadEvent( SerialNewsLoadEvent.STACK_COMPLETE ));
			}
		}
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private static var _instance:SerialNewsLoadManager;
		private var _amf:AMFConnecter;
		
		private var _isLoading:Boolean = false;
		private var _nowLoadKey:String;
		
		private var _loadStack:Array;
		private var _currentIDStack:Array;
		private var _loadedAry:Array;
		private var _resultFuncDict:Dictionary;
		private var _modelDict:Dictionary;
		private var _loadCheckDict:Dictionary;
		private var _checkIDDict:Dictionary;
		private var _sizeDict:Dictionary;
	}
}