/*////////////////////////////////////////////

WorldWordWeb

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/03/23

Copyright 2010 glasses factory
http://glasses-factory.net

see:http://meemeer.sitemix.jp/blog/archives/462

/*////////////////////////////////////////////

package net.glassesfactory.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;

	public class AMFConnecter
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		public function get dispatcher():EventDispatcher{ return _dispatcher; }
		
		public var data:Object;
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function AMFConnecter( caller:Function = null, gatewayURL:String = "" )
		{
			if( caller != AMFConnecter.getInstance )
			{
				throw new Error("直接インスタンス化はできません");
			}
			else
			{
				_gatewayURL = gatewayURL;
				_init();
			}
		}
		
		
		/**
		 * インスタンスを取得 
		 * @param gatewayURL
		 * @return 
		 * 
		 */		
		public static function getInstance( gatewayURL:String = "" ):AMFConnecter
		{
			if( _instance == null )
			{
				_instance = new AMFConnecter( arguments.callee, gatewayURL );
			}
			return _instance;
		}
		
		
		public function call( func:String, callback:Function, ...args:Array ):void
		{
			_callback = callback;
			var params:Array = [func, new Responder( _onResultdHandler, _onFaultHandler )];
			trace( args );
			params.push.apply( params, args );
			_nc.call.apply( _nc, params );
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		/**
		 * 初期化  
		 */		
		private function _init():void
		{
			_dispatcher = new EventDispatcher();
			
			_nc = new NetConnection();
			_nc.objectEncoding = ObjectEncoding.AMF3;
			_nc.addEventListener( NetStatusEvent.NET_STATUS, _netStatusHandler );
			_nc.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler );
			_nc.connect(_gatewayURL);
		}
		
		private function _onResultdHandler( result:Object ):void
		{
			if( _callback != null )
			{
				data = _callback.apply( null, [result] );
			}
			else
			{
				data = result;
			}
			_dispatcher.dispatchEvent( new Event( Event.COMPLETE ));
		}
		
		
		private function _onFaultHandler( fault:Object ):void
		{
			data = fault;
			trace( "fault:" + fault.description + ' code: ' + fault.code + ' details: ' + fault.details + ' level: ' + fault.level + ' line: ' + fault.line );			
			_dispatcher.dispatchEvent( new Event( Event.COMPLETE ));
		}
		
		/**
		 * ねっとすてーたす 
		 * @param e
		 */		
		private function _netStatusHandler( e:NetStatusEvent ):void
		{
			trace("Connection error, error code: (" +e.info.code + ")", "System message");
		}
		
		private function _securityErrorHandler( e:SecurityErrorEvent ):void
		{
			trace( "SecurityError, erro code: (" + e.text + ")", "from AMFConnecter");
		}
		
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private static var _instance:AMFConnecter;
		
		private var _gatewayURL:String;
		private var _nc:NetConnection;
		
		private var _dispatcher:EventDispatcher;
		private var _callback:Function;
		
	}
}