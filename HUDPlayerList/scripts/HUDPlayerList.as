package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   import utils.*;
   
   public class HUDPlayerList extends MovieClip
   {
      
      public static const MOD_NAME:String = "HUDPlayerList";
      
      public static const MOD_VERSION:String = "1.3.1";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      public static const CONFIG_FILE:String = "../HUDPlayerList.json";
      
      public static const CONFIG_RELOAD_TIME:uint = 10050;
      
      private static const DATA_SEPARATOR:String = "separator";
      
      private static const DATA_EMPTY_SPACE:String = "emptyspace";
      
      private static const DATA_TEXT:String = "text";
      
      private static const DATA_GROUP:String = "group";
      
      private static const IS_FRIEND:String = "isFriend";
      
      private static const IS_HIDDEN:String = "isHidden";
      
      private static const IS_SERVER_FULL:String = "isServerFull";
      
      private static const IS_TEXTCHAT_USER:String = "isTextChatUser";
      
      private static const PLAYER_WANTED:String = "MostWanted";
      
      private static const PLAYER_REMOTE:String = "PlayerRemote";
      
      private static const PLAYER_LOCAL:String = "PlayerLocal";
      
      private static const PLAYER_TEAM_LEADER:String = "TeamLeader";
      
      private static const PLAYER_TEAM_MEMBER:String = "TeamMember";
      
      private static const CAMP_MARKER:String = "YourCampMarker";
      
      private static const MAX_PLAYERS_PRIVATE:uint = 8;
      
      private static const MAX_PLAYERS_PUBLIC:uint = 26;
      
      private static const SORT_BY_CUSTOM:String = "custom";
      
      private static const SORT_BY_PROPERTY:String = "property";
      
      private static const SORT_BY_LEVEL:String = "level";
      
      private static const SORT_BY_BOUNTY:String = "bounty";
      
      private static const STRING_NAME:String = "{name}";
      
      private static const STRING_TYPE:String = "{type}";
      
      private static const STRING_LEVEL:String = "{level}";
      
      private static const STRING_BOUNTY:String = "{bounty}";
      
      private static const STRING_CAPS:String = "{caps}";
      
      private static const STRING_VALUE:String = "{value}";
      
      private static const STRING_CHARACTER_NAME:String = "{characterName}";
      
      private static const STRING_ANGLE:String = "{angle}";
      
      private static const STRING_ANGLE_COMPASS:String = "{angleCompass}";
      
      private static const STRING_DISTANCE:String = "{distance}";
      
      private static const STRING_DIRECTION:String = "{direction}";
      
      private static const STRING_VENDOR_DATA:String = "{vendorData}";
      
      private static const STRINGS_COORDINATES:* = [STRING_ANGLE,STRING_ANGLE_COMPASS,STRING_DISTANCE,STRING_DIRECTION];
      
      private static const TITLE_HUDMENU:String = "HUDMenu";
      
      private static const TITLE_TEXTCHAT:String = "TextChat";
      
      private static const TITLE_LOADER:String = "flash.display::Loader";
      
      private static const TITLE_DELIMITER:String = "<";
      
      private static const MAIN_MENU:String = "MainMenu";
      
      private static const VENDING_CATEGORY_NAMES:Array = ["{APPAREL}","{ARMOR0}","{ARMOR1}","{ARMOR2}","{ARMOR3}","{ARMOR4}","{WEAPON0}","{WEAPON1}","{WEAPON2}","{WEAPON3}","{WEAPON4}","{MODS}","{MODS_WEAPON1}","{MODS_WEAPON2}","{MODS_WEAPON3}","{MODS_WEAPON4}","{MODS_ARMOR1}","{MODS_ARMOR2}","{MODS_ARMOR3}","{MODS_ARMOR4}","{MODS_PA1}","{MODS_PA2}","{MODS_PA3}","{MODS_PA4}","{STIMPAK}","{MEDS}","{FOOD}","{DRINK}","{AMMO}","{EXPLOSIVE}","{JUNK}","{PLAN}","{MISC}"];
      
      private static const VENDING_CATEGORIES:* = {
         "{APPAREL}":0,
         "{ARMOR0}":1,
         "{ARMOR1}":2,
         "{ARMOR2}":3,
         "{ARMOR3}":4,
         "{ARMOR4}":5,
         "{WEAPON0}":6,
         "{WEAPON1}":7,
         "{WEAPON2}":8,
         "{WEAPON3}":9,
         "{WEAPON4}":10,
         "{MODS}":11,
         "{MODS_WEAPON1}":12,
         "{MODS_WEAPON2}":13,
         "{MODS_WEAPON3}":14,
         "{MODS_WEAPON4}":15,
         "{MODS_ARMOR1}":16,
         "{MODS_ARMOR2}":17,
         "{MODS_ARMOR3}":18,
         "{MODS_ARMOR4}":19,
         "{MODS_PA1}":20,
         "{MODS_PA2}":21,
         "{MODS_PA3}":22,
         "{MODS_PA4}":23,
         "{STIMPAK}":24,
         "{MEDS}":25,
         "{FOOD}":26,
         "{DRINK}":27,
         "{AMMO}":28,
         "{EXPLOSIVE}":29,
         "{JUNK}":30,
         "{PLAN}":31,
         "{MISC}":32
      };
      
      private static const RAD2DEG:Number = 180 / Math.PI;
      
      private static const MAP_DISTANCE_CONST:Number = 5005;
      
      private static const LOCALIZED_HEADINGS:* = ["$Compass_West","$Compass_North","$Compass_East","$Compass_South"];
      
      private static const HUDTOOLS_MENU_TOGGLE_VENDORS:String = MOD_NAME + "_TOGGLE_VENDORS";
      
      private static const HUDTOOLS_MENU_TOGGLE_VISIBILITY:String = MOD_NAME + "_TOGGLE_VISIBILITY";
      
      private static const HUDTOOLS_MENU_HIDE:String = MOD_NAME + "_HIDE";
      
      private static const HUDTOOLS_MENU_RELOAD_CONFIG:String = MOD_NAME + "_RELOAD_CONFIG";
      
      private static var HEADINGS:* = [];
      
      private var _lastConfigUpdateTime:Number = 0;
      
      private var _lastRenderTime:Number = 0;
      
      private var topLevel:* = null;
      
      private var dummy_tf:TextField;
      
      private var timer:Timer;
      
      private var configTimer:Timer;
      
      private var displayTimer:Timer;
      
      private var lastConfig:String;
      
      private var HUDModeData:*;
      
      private var AccountInfoData:*;
      
      private var CharacterInfoData:*;
      
      private var CharacterNameData:*;
      
      private var PublicTeamsData:*;
      
      private var MapMenuData:*;
      
      private var vendorData:* = {};
      
      private var campMarkers:* = {};
      
      private var playerPosition:*;
      
      private var visitedCamps:* = {};
      
      private var _players:Array;
      
      private var _playerCount:int;
      
      private var _textChatUsers:Array;
      
      private var players_tf:Array = [];
      
      private var players_index:int = 0;
      
      private var textFormat:TextFormat;
      
      private var yOffset:Number = 0;
      
      private var separators:Array = [];
      
      private var maxServerPlayers:uint = 0;
      
      private var textChat:*;
      
      private var isHudMenu:Boolean = true;
      
      private var isInMainMenu:Boolean = true;
      
      private var toggleVisibility:Boolean = false;
      
      private var forceHide:Boolean = false;
      
      private var hudTools:SharedHUDTools;
      
      private var toggleVendors:Boolean = false;
      
      private var lastLevelData:* = {};
      
      private var isKeyDownDetected:Object = {};
      
      public function HUDPlayerList()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
         this.HUDModeData = BSUIDataManager.GetDataFromClient("HUDModeData");
         this.AccountInfoData = BSUIDataManager.GetDataFromClient("AccountInfoData");
         this.CharacterInfoData = BSUIDataManager.GetDataFromClient("CharacterInfoData");
         this.CharacterNameData = BSUIDataManager.GetDataFromClient("CharacterNameData");
         this.PublicTeamsData = BSUIDataManager.GetDataFromClient("PublicTeamsData");
         this.MapMenuData = BSUIDataManager.GetDataFromClient("MapMenuData");
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
      }
      
      private static function getDirection(y:Number, x:Number) : String
      {
         var angle:Number = Math.atan2(y,x);
         return getDirection(angle);
      }
      
      private static function getDirection(atan2angle:Number) : String
      {
         if(HEADINGS.length == 0)
         {
            return "";
         }
         var angle:Number = atan2angle;
         var increment:Number = 2 * Math.PI / HEADINGS.length;
         var testangle:Number = -Math.PI + increment / 2;
         var i:int = 0;
         while(angle > testangle)
         {
            i++;
            if(i > HEADINGS.length - 1)
            {
               break;
            }
            testangle += increment;
         }
         return HEADINGS[i % HEADINGS.length];
      }
      
      private static function getDistance(x:Number, y:Number) : Number
      {
         return Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == TITLE_HUDMENU)
            {
               this.isInMainMenu = false;
               this.hudTools = new SharedHUDTools(MOD_NAME);
               this.hudTools.RegisterMenu(this.onBuildMenu,this.onSelectMenu);
            }
            else
            {
               this.isHudMenu = false;
               BSUIDataManager.Subscribe("MenuStackData",this.updateIsMainMenu);
               stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
               stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler,false,0,true);
            }
            this.initConfigTimer();
            this.loadConfig();
            BSUIDataManager.Subscribe("RecentActivitiesData",this.onRecentActivitiesDataUpdate);
            trace(MOD_NAME + " added to stage: " + getQualifiedClassName(this.topLevel));
         }
         else
         {
            trace(MOD_NAME + " not added to stage: " + getQualifiedClassName(this.topLevel));
            ShowHUDMessage("Not added to stage: " + getQualifiedClassName(this.topLevel));
         }
      }
      
      public function removedFromStageHandler(param1:Event) : *
      {
         BSUIDataManager.Unsubscribe("MenuStackData",this.updateIsMainMenu);
         BSUIDataManager.Unsubscribe("RecentActivitiesData",this.onRecentActivitiesDataUpdate);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         if(stage)
         {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
            stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
         }
         if(this.configTimer)
         {
            this.configTimer.removeEventListener(TimerEvent.TIMER,this.loadConfig);
         }
         if(this.displayTimer)
         {
            this.displayTimer.removeEventListener(TimerEvent.TIMER,this.displayPlayerList);
         }
         if(this.hudtools)
         {
            this.hudtools.Shutdown();
         }
      }
      
      public function initConfigTimer() : void
      {
         this.configTimer = new Timer(CONFIG_RELOAD_TIME);
         this.configTimer.addEventListener(TimerEvent.TIMER,this.loadConfig,false,0,true);
         this.configTimer.start();
      }
      
      public function onBuildMenu(parentItem:String = null) : *
      {
         try
         {
            if(parentItem == MOD_NAME)
            {
               if(config && config.disableRealTimeEdit)
               {
                  this.hudTools.AddMenuItem(HUDTOOLS_MENU_RELOAD_CONFIG,"Reload Config",true,false,250);
               }
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_TOGGLE_VENDORS,"Hide Vendors",true,false,250);
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_TOGGLE_VISIBILITY,"Toggle Visible",true,false,250);
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_HIDE,"Force Hide",true,false,250);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSelectMenu(selectItem:String) : *
      {
         try
         {
            if(selectItem == HUDTOOLS_MENU_TOGGLE_VENDORS)
            {
               this.toggleVendors = !this.toggleVendors;
            }
            else if(selectItem == HUDTOOLS_MENU_TOGGLE_VISIBILITY)
            {
               this.toggleVisibility = !this.toggleVisibility;
            }
            else if(selectItem == HUDTOOLS_MENU_HIDE)
            {
               this.forceHide = !this.forceHide;
            }
            else if(selectItem == HUDTOOLS_MENU_RELOAD_CONFIG)
            {
               config.disableRealTimeEdit = false;
               this.loadConfig();
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function keyDownHandler(event:Event) : void
      {
         try
         {
            this.isKeyDownDetected[event.keyCode] = true;
            if(!config || !players_tf)
            {
               return;
            }
            if(config.debugKeys)
            {
               displayMessage("keyDown: " + event.keyCode + " - " + Buttons.getButtonKey(event.keyCode));
            }
            this.handleKey(event);
         }
         catch(e:Error)
         {
            displayMessage("Error keyDownHandler: " + e);
         }
      }
      
      public function keyUpHandler(event:Event) : void
      {
         try
         {
            if(!config || !players_tf)
            {
               return;
            }
            if(config.debugKeys)
            {
               displayMessage("keyUp (kd:" + Boolean(this.isKeyDownDetected[event.keyCode]) + "): " + event.keyCode + " - " + Buttons.getButtonKey(event.keyCode));
            }
            if(!this.isKeyDownDetected[event.keyCode])
            {
               this.handleKey(event);
            }
         }
         catch(e:Error)
         {
            displayMessage("Error keyUpHandler: " + e);
         }
      }
      
      private function handleKey(event:Event) : void
      {
         if(event.keyCode == config.toggleVendorsHotkey)
         {
            this.toggleVendors = !this.toggleVendors;
         }
         if(event.keyCode == config.toggleVisibilityHotkey)
         {
            this.toggleVisibility = !this.toggleVisibility;
         }
         if(event.keyCode == config.forceHideHotkey)
         {
            this.forceHide = !this.forceHide;
         }
      }
      
      private function updateIsMainMenu(event:FromClientDataEvent) : void
      {
         try
         {
            this.isInMainMenu = Boolean(event) && Boolean(event.data) && Boolean(event.data.menuStackA) && Boolean(event.data.menuStackA.some(function(x:*):*
            {
               return x.menuName == MAIN_MENU;
            }));
            if(this.isInMainMenu)
            {
               this.maxServerPlayers = 0;
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onRecentActivitiesDataUpdate(event:FromClientDataEvent) : void
      {
         var vendors:*;
         var i:int;
         try
         {
            vendors = {};
            i = 0;
            while(i < event.data.recentActivities.length)
            {
               if(event.data.recentActivities[i].type == 3)
               {
                  vendors[event.data.recentActivities[i].mapMarkerId] = event.data.recentActivities[i].vendingCategoryCounts;
               }
               i++;
            }
            this.vendorData = vendors;
         }
         catch(e:Error)
         {
         }
      }
      
      public function loadConfig() : void
      {
         var loaderComplete:Function;
         var ioErrorHandler:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            if(config && Boolean(config.disableRealTimeEdit))
            {
               return;
            }
            loaderComplete = function(param1:Event):void
            {
               var jsonData:Object;
               try
               {
                  if(lastConfig != loader.data)
                  {
                     jsonData = new JSONDecoder(loader.data,true).getValue();
                     HUDPlayerListConfig.init(jsonData);
                     initTextField();
                     initTimers();
                     _lastConfigUpdateTime = getTimer();
                     lastConfig = loader.data;
                  }
               }
               catch(e:Error)
               {
                  ShowHUDMessage("Error parsing config: " + e);
               }
            };
            ioErrorHandler = function(param1:*):void
            {
               ShowHUDMessage("Error loading config: " + param1.text);
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete,false,0,true);
            loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error loading config: " + e);
         }
      }
      
      private function initTextField() : void
      {
         this.dummy_tf = new TextField();
         var i:int = 0;
         var headings:* = [];
         while(i < 4)
         {
            GlobalFunc.SetText(this.dummy_tf,LOCALIZED_HEADINGS[i]);
            headings.push(this.dummy_tf.text);
            i++;
         }
         HEADINGS = [headings[0],headings[0] + headings[1] + headings[0],headings[1] + headings[0],headings[1] + headings[1] + headings[0],headings[1],headings[1] + headings[1] + headings[2],headings[1] + headings[2],headings[2] + headings[1] + headings[2],headings[2],headings[2] + headings[3] + headings[2],headings[3] + headings[2],headings[3] + headings[3] + headings[2],headings[3],headings[3] + headings[3] + headings[0],headings[3] + headings[0],headings[0] + headings[3] + headings[0]];
         GlobalFunc.SetText(this.dummy_tf,"");
         this.formatMessage();
      }
      
      private function initTimers() : void
      {
         if(this.displayTimer)
         {
            this.displayTimer.removeEventListener(TimerEvent.TIMER,this.displayPlayerList);
         }
         this.displayTimer = new Timer(config.refresh);
         this.displayTimer.addEventListener(TimerEvent.TIMER,this.displayPlayerList,false,0,true);
         this.displayTimer.start();
      }
      
      public function get isReloadable() : Boolean
      {
         return true;
      }
      
      public function get config() : Object
      {
         return HUDPlayerListConfig.get();
      }
      
      public function get elapsedTime() : Number
      {
         return getTimer() / 1000;
      }
      
      public function get timeSinceLastConfigUpdate() : Number
      {
         return (getTimer() - this._lastConfigUpdateTime) / 1000;
      }
      
      public function formatMessage() : void
      {
         this.dummy_tf.htmlText = MOD_VERSION;
         this.dummy_tf.x = config.x;
         this.dummy_tf.y = config.y;
         this.dummy_tf.width = config.width;
         this.dummy_tf.background = false;
         TextFieldEx.setTextAutoSize(this.dummy_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         this.dummy_tf.autoSize = TextFieldAutoSize.LEFT;
         this.dummy_tf.wordWrap = false;
         this.dummy_tf.multiline = true;
         this.dummy_tf.visible = true;
         this.textFormat = new TextFormat(config.textFont,config.textSize,config.textColor);
         this.textFormat.align = config.textAlign;
         this.dummy_tf.defaultTextFormat = this.textFormat;
         this.dummy_tf.setTextFormat(this.textFormat);
         this.dummy_tf.filters = [new DropShadowFilter(2,45,0,1,1,1,1,BitmapFilterQuality.HIGH)];
         this.alpha = config.alpha;
         this.blendMode = config.blendMode;
         resetMessages(true);
      }
      
      public function resetMessages(setFormat:Boolean = false) : void
      {
         this.separators = [];
         this.graphics.clear();
         this.players_index = 0;
         this.yOffset = 0;
         var p:int = 0;
         while(p < players_tf.length)
         {
            if(players_tf[p] != null)
            {
               players_tf[p].visible = false;
               if(setFormat)
               {
                  players_tf[p].defaultTextFormat = this.textFormat;
                  players_tf[p].setTextFormat(this.textFormat);
                  players_tf[p].filters = Boolean(config.textShadow) ? this.dummy_tf.filters : [];
                  players_tf[p].blendMode = config.textBlendMode;
               }
               else
               {
                  players_tf[p].textColor = config.textColor;
               }
            }
            p++;
         }
      }
      
      public function createTextfield() : TextField
      {
         tf = new TextField();
         tf.multiline = false;
         tf.wordWrap = false;
         tf.defaultTextFormat = this.textFormat;
         TextFieldEx.setTextAutoSize(tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         tf.setTextFormat(this.textFormat);
         if(config)
         {
            tf.filters = Boolean(config.textShadow) ? this.dummy_tf.filters : [];
            tf.blendMode = config.textBlendMode;
         }
         addChild(tf);
         return tf;
      }
      
      public function applyConfig(tf:TextField) : void
      {
         tf.x = config.x;
         tf.background = false;
         tf.width = config.width;
         tf.height = this.dummy_tf.height;
         if(players_index == 0)
         {
            tf.y = config.y;
         }
         else
         {
            tf.y = LastDisplayPlayer.y + LastDisplayPlayer.height + config.ySpacing + yOffset;
            yOffset = 0;
         }
         tf.visible = true;
      }
      
      public function displayMessage(text:String) : void
      {
         if(players_tf.length < players_index || players_tf[players_index] == null)
         {
            players_tf[players_index] = createTextfield();
         }
         applyConfig(players_tf[players_index]);
         players_tf[players_index].text = text;
         ++players_index;
      }
      
      public function removeLastMessage() : void
      {
         if(players_tf.length >= players_index && players_index > 0)
         {
            --players_index;
            players_tf[players_index].visible = false;
            players_tf[players_index].defaultTextFormat = this.textFormat;
            players_tf[players_index].setTextFormat(this.textFormat);
         }
      }
      
      public function drawBackground() : void
      {
         if(config.background)
         {
            this.graphics.beginFill(config.backgroundColor,config.backgroundAlpha);
            this.graphics.drawRect(config.x,config.y,config.width,LastDisplayPlayer.y + LastDisplayPlayer.height - config.y);
            this.graphics.endFill();
         }
         if(config.anchor == "bottom")
         {
            this.y = -(LastDisplayPlayer.y + LastDisplayPlayer.height - config.y);
         }
         else if(this.y != 0)
         {
            this.y = 0;
         }
      }
      
      public function get LastDisplayPlayer() : TextField
      {
         if(players_index == 0)
         {
            return players_tf[players_index];
         }
         return players_tf[players_index - 1];
      }
      
      public function customSort(objA:Object, objB:Object) : int
      {
         var indexA:int = int.MAX_VALUE;
         var indexB:int = int.MAX_VALUE;
         var textA:String = (objA.name + objA.type + (Boolean(objA.isFriend) ? IS_FRIEND : "") + (Boolean(objA.isTextChatUser) ? IS_TEXTCHAT_USER : "")).toLowerCase();
         var textB:String = (objB.name + objB.type + (Boolean(objB.isFriend) ? IS_FRIEND : "") + (Boolean(objB.isTextChatUser) ? IS_TEXTCHAT_USER : "")).toLowerCase();
         config.sortOrder.forEach(function(phrase:String, index:int, array:Array):void
         {
            if(textA.indexOf(phrase) != -1 && index < indexA)
            {
               indexA = index;
            }
            if(textB.indexOf(phrase) != -1 && index < indexB)
            {
               indexB = index;
            }
         });
         if(indexA < indexB)
         {
            return -1;
         }
         if(indexA > indexB)
         {
            return 1;
         }
         return textA.localeCompare(textB);
      }
      
      public function getCustomColor(name:String) : Number
      {
         if(config.customColors[name] != null)
         {
            return config.customColors[name];
         }
         return config.textColor;
      }
      
      public function applyColor(name:String) : Boolean
      {
         if(config.customColors[name] != null)
         {
            LastDisplayPlayer.textColor = config.customColors[name];
            return true;
         }
         return false;
      }
      
      public function addSeparator(data:String) : void
      {
         if(data == null || data.length == 0)
         {
            return;
         }
         data = data.replace(" ","");
         var parts:Array = data.split(":");
         var color:Number = Number(config.textColor);
         if(parts.length > 1)
         {
            var height:Number = Parser.parseNumber(parts[1],0);
            if(parts.length > 2)
            {
               color = Parser.parseNumber(parts[2],getCustomColor(parts[2]));
            }
            if(players_index == 0)
            {
               var y:Number = Number(config.y);
            }
            else
            {
               y = LastDisplayPlayer.y + LastDisplayPlayer.height + config.ySpacing / 2 + yOffset;
            }
            yOffset += height;
            separators.push({
               "y":y,
               "height":height,
               "color":color
            });
         }
      }
      
      public function addEmptySpace(data:String) : void
      {
         if(data == null || data.length == 0)
         {
            return;
         }
         var parts:Array = data.split(":");
         var space:Number = Parser.parseNumber(parts[1],0);
         yOffset += space;
      }
      
      public function addCustomText(data:String) : void
      {
         if(data == null || data.length == 0)
         {
            return;
         }
         data = data.replace("/:","/COLON/");
         var parts:Array = data.split(":");
         if(parts.length == 3)
         {
            var color:Number = Parser.parseNumber(parts[1],getCustomColor(parts[1]));
            var text:String = parts[2];
            text = text.replace("/COLON/",":");
            displayMessage(text);
            LastDisplayPlayer.textColor = color;
         }
      }
      
      public function displayGroup(groupName:*) : void
      {
         var propType:int = 0;
         switch(groupName)
         {
            case PLAYER_REMOTE:
            case PLAYER_LOCAL:
            case PLAYER_TEAM_LEADER:
            case PLAYER_TEAM_MEMBER:
            case PLAYER_WANTED:
            case IS_HIDDEN:
               propType = 1;
               break;
            case IS_FRIEND:
            case IS_TEXTCHAT_USER:
               propType = 2;
         }
         var filteredPlayers:Array = [];
         var i:int = 0;
         if(propType == 1)
         {
            while(i < _players.length)
            {
               if(groupName == _players[i].type)
               {
                  filteredPlayers.push(_players[i]);
                  _players.splice(i,1);
               }
               else
               {
                  i++;
               }
            }
         }
         else if(propType == 2)
         {
            while(i < _players.length)
            {
               if(_players[i][groupName])
               {
                  filteredPlayers.push(_players[i]);
                  _players.splice(i,1);
               }
               else
               {
                  i++;
               }
            }
         }
         else
         {
            filteredPlayers = _players;
            _players = [];
         }
         displayPlayers(filteredPlayers);
      }
      
      public function drawSeparators() : void
      {
         var s:int = 0;
         while(s < separators.length)
         {
            this.graphics.beginFill(separators[s].color);
            this.graphics.drawRect(config.x,separators[s].y,config.width,separators[s].height);
            this.graphics.endFill();
            s++;
         }
      }
      
      public function formatPlayer(player:Object) : String
      {
         var textToDisplay:String = config.format;
         var fi:int = 0;
         while(fi < config.formats.Keys.length)
         {
            var f:String = config.formats.Keys[fi];
            switch(f)
            {
               case SORT_BY_BOUNTY:
                  if(player.type == PLAYER_WANTED)
                  {
                     textToDisplay = textToDisplay.replace(STRING_BOUNTY,config.formats[f]).replace(STRING_CAPS,player.bounty);
                  }
                  else
                  {
                     textToDisplay = textToDisplay.replace(STRING_BOUNTY,"");
                  }
                  break;
               case PLAYER_REMOTE:
               case PLAYER_LOCAL:
               case PLAYER_TEAM_LEADER:
               case PLAYER_TEAM_MEMBER:
               case PLAYER_WANTED:
               case IS_HIDDEN:
                  if(player.type == f)
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}",config.formats[f]);
                  }
                  else
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}","");
                  }
                  break;
               case IS_FRIEND:
               case IS_TEXTCHAT_USER:
                  if(player[f])
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}",config.formats[f]);
                  }
                  else
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}","");
                  }
                  break;
            }
            fi++;
         }
         return textToDisplay;
      }
      
      public function sortPlayers(players:Array) : Array
      {
         if(config.sortBy == SORT_BY_CUSTOM)
         {
            players.sort(customSort);
         }
         else if(config.sortBy == SORT_BY_PROPERTY)
         {
            var sortOptions:Array = new Array(config.sortOrder.length);
            var p:int = 0;
            while(p < config.sortOrder.length)
            {
               if(config.sortOrder[p] == SORT_BY_LEVEL || config.sortOrder[p] == SORT_BY_BOUNTY)
               {
                  sortOptions[p] = Array.NUMERIC | Array.DESCENDING;
               }
               else
               {
                  sortOptions[p] = Array.CASEINSENSITIVE;
               }
               p++;
            }
            players = players.sortOn(config.sortOrder,sortOptions);
         }
         if(config.reverseSort)
         {
            players.reverse();
         }
         return players;
      }
      
      public function displayPlayers(players:Array) : void
      {
         var p:int = 0;
         var l:int = int(players.length);
         var player:Object = null;
         while(p < l)
         {
            player = players[p];
            if(this.isValidPlayerToShow(player))
            {
               var textToDisplay:String = this.formatPlayer(player);
               textToDisplay = textToDisplay.replace(STRING_NAME,player.name).replace(STRING_TYPE,player.type).replace(STRING_LEVEL,player.level);
               var yDiff:Number = player.y - playerPosition.y;
               var xDiff:Number = player.x - playerPosition.x;
               var distance:int = int(getDistance(xDiff,yDiff) * MAP_DISTANCE_CONST);
               var angle:Number = Math.atan2(yDiff,xDiff);
               var direction:String = getDirection(angle);
               var iangle:int = (360 - angle * RAD2DEG) % 360;
               var iangleCompass:int = (450 + angle * RAD2DEG) % 360;
               textToDisplay = textToDisplay.replace(STRING_ANGLE,iangle).replace(STRING_ANGLE_COMPASS,iangleCompass).replace(STRING_DIRECTION,direction).replace(STRING_DISTANCE,distance);
               if(player.type == PLAYER_LOCAL)
               {
                  textToDisplay = textToDisplay.replace(STRING_CHARACTER_NAME,this.CharacterNameData.data.characterName);
               }
               else
               {
                  textToDisplay = textToDisplay.replace(STRING_CHARACTER_NAME,"");
               }
               displayMessage(textToDisplay);
               var colorApplied:Boolean = false;
               var isVendorDataInLine:Boolean = false;
               if(player.type == PLAYER_WANTED)
               {
                  colorApplied = applyColor(PLAYER_WANTED);
               }
               if(!colorApplied && player[IS_FRIEND])
               {
                  colorApplied = applyColor(IS_FRIEND);
               }
               if(!colorApplied && player[IS_TEXTCHAT_USER])
               {
                  colorApplied = applyColor(IS_TEXTCHAT_USER);
               }
               if(!colorApplied)
               {
                  applyColor(player.type);
               }
               var color:Number = LastDisplayPlayer.textColor;
               var vendorDataString:String = "";
               var indexOfVendorDataInFormat:int = int(LastDisplayPlayer.text.indexOf(STRING_VENDOR_DATA));
               if(config.vendorData.enabled && !this.toggleVendors)
               {
                  var marker:Object = campMarkers[player.name];
                  var hasVendorData:Boolean = false;
                  if(marker != null && vendorData[marker.markerId] != null && vendorData[marker.markerId].length > 0)
                  {
                     yDiff = marker.y - playerPosition.y;
                     xDiff = marker.x - playerPosition.x;
                     distance = int(getDistance(xDiff,yDiff) * MAP_DISTANCE_CONST);
                     if(distance < 25)
                     {
                        visitedCamps[player.name] = true;
                     }
                     if(!(config.vendorData.hideVisitedCamps && visitedCamps[player.name]))
                     {
                        angle = Math.atan2(yDiff,xDiff);
                        direction = getDirection(angle);
                        iangle = (360 - angle * RAD2DEG) % 360;
                        iangleCompass = (450 + angle * RAD2DEG) % 360;
                        var i:int = 0;
                        if(visitedCamps[player.name] && config.customColors["visitedCamp"] != null)
                        {
                           color = Number(config.customColors["visitedCamp"]);
                        }
                        else if(Boolean(config.vendorData.usePlayerColor))
                        {
                           color = LastDisplayPlayer.textColor;
                        }
                        else
                        {
                           color = getCustomColor("vendorData");
                        }
                        while(i < config.vendorData.format.length)
                        {
                           var vdata:String = formatVendingData(config.vendorData.format[i],vendorData[marker.markerId]);
                           if(vdata != "")
                           {
                              hasVendorData = true;
                              vdata = vdata.replace(STRING_ANGLE,iangle).replace(STRING_ANGLE_COMPASS,iangleCompass).replace(STRING_DIRECTION,direction).replace(STRING_DISTANCE,distance);
                              if(indexOfVendorDataInFormat != -1)
                              {
                                 isVendorDataInLine = true;
                                 vendorDataString += vdata;
                              }
                              else
                              {
                                 displayMessage(vdata);
                                 LastDisplayPlayer.textColor = color;
                              }
                           }
                           i++;
                        }
                     }
                  }
                  if(isVendorDataInLine)
                  {
                     var lenAfterVendorDataInFormat:int = LastDisplayPlayer.text.length - LastDisplayPlayer.text.indexOf(STRING_VENDOR_DATA) + STRING_VENDOR_DATA.length + 1;
                     LastDisplayPlayer.text = LastDisplayPlayer.text.replace(STRING_VENDOR_DATA,vendorDataString);
                     var frmt:TextFormat = new TextFormat();
                     frmt.color = color;
                     LastDisplayPlayer.setTextFormat(frmt,indexOfVendorDataInFormat,indexOfVendorDataInFormat + vendorDataString.length);
                  }
                  else if(!hasVendorData && (config.vendorData.hidePlayersWithoutVendorData.indexOf(player.type) != -1 || hasAnyOfProperties(player,config.vendorData.hidePlayersWithoutVendorData)))
                  {
                     removeLastMessage();
                  }
               }
               if(!hasVendorData && LastDisplayPlayer.text.indexOf(STRING_VENDOR_DATA) != -1)
               {
                  LastDisplayPlayer.text = LastDisplayPlayer.text.replace(STRING_VENDOR_DATA,"");
               }
            }
            p++;
         }
      }
      
      private function hasAnyOfProperties(player:Object, props:Array) : Boolean
      {
         var i:int = 0;
         while(i < props.length)
         {
            if(player[props[i]])
            {
               return true;
            }
            i++;
         }
         return false;
      }
      
      private function formatVendingData(format:String, vendorData:Array) : String
      {
         if(format == null || format.length == 0)
         {
            return "";
         }
         var textToDisplay:String = format;
         var hasData:Boolean = false;
         for each(cat in VENDING_CATEGORY_NAMES)
         {
            if(textToDisplay.indexOf(cat) != -1)
            {
               if(vendorData.length > VENDING_CATEGORIES[cat] && vendorData[VENDING_CATEGORIES[cat]] != 0 && config.vendorData.formats[cat] != null)
               {
                  textToDisplay = textToDisplay.replace(cat,config.vendorData.formats[cat].replace(STRING_VALUE,vendorData[VENDING_CATEGORIES[cat]]));
                  hasData = true;
               }
               else
               {
                  textToDisplay = textToDisplay.replace(cat,"");
               }
            }
         }
         return hasData ? textToDisplay : "";
      }
      
      public function displayPlayerList() : void
      {
         var t1:Number;
         var dataField:String;
         var parts:Array;
         var d:int;
         try
         {
            t1 = Number(getTimer());
            this.visible = !this.forceHide && Boolean(this.isValidHUDMode() ^ this.toggleVisibility);
            if(!this.visible)
            {
               return;
            }
            this.resetMessages();
            _players = sortPlayers(this.getPlayers());
            if(maxServerPlayers == 0)
            {
               maxServerPlayers = Boolean(this.AccountInfoData.data.isOnPrivateWorld) ? MAX_PLAYERS_PRIVATE : MAX_PLAYERS_PUBLIC;
            }
            if(config.displayData && config.displayData.length > 0)
            {
               d = 0;
               while(d < config.displayData.length)
               {
                  dataField = config.displayData[d];
                  parts = dataField.split(":");
                  switch(parts[0])
                  {
                     case "debug":
                        displayMessage("HUDModeData: " + this.HUDModeData.data);
                        displayMessage("AccountInfoData: " + this.AccountInfoData.data);
                        displayMessage("PublicTeamsData: " + this.PublicTeamsData.data);
                        displayMessage("MapMenuData: " + this.MapMenuData.data);
                        displayMessage("x:" + this.MapMenuData.data.StartX + ", y:" + this.MapMenuData.data.StartY + ", zoom:" + this.MapMenuData.data.savedZoomScale);
                        displayMessage("campMarkers");
                        for(m in this.campMarkers)
                        {
                           displayMessage(m + ":" + this.campMarkers[m].x + ", " + this.campMarkers[m].y + ", " + this.campMarkers[m].markerId);
                        }
                        displayMessage("vendorData");
                        for(v in this.vendorData)
                        {
                           displayMessage(v + ":" + this.vendorData[v]);
                        }
                        displayMessage("----------");
                        break;
                     case "showVersion":
                        displayMessage(FULL_MOD_NAME + (this.isHudMenu ? "" : " (Overlay)"));
                        applyColor(dataField);
                        break;
                     case "showLastConfigUpdate":
                        displayMessage("ConfigUpdate: " + GlobalFunc.FormatTimeString(this.timeSinceLastConfigUpdate) + " ago");
                        applyColor(dataField);
                        break;
                     case "showElapsedTime":
                        displayMessage("ElapsedTime: " + GlobalFunc.FormatTimeString(this.elapsedTime));
                        applyColor(dataField);
                        break;
                     case "showHUDMode":
                        displayMessage("HUDMode: " + (!this.isInMainMenu ? this.HUDModeData.data.hudMode : MAIN_MENU));
                        applyColor(dataField);
                        break;
                     case "showPlayerCount":
                        displayMessage("Players: " + _playerCount + "/" + maxServerPlayers);
                        applyColor(_playerCount >= 0.9 * maxServerPlayers ? IS_SERVER_FULL : dataField);
                        break;
                     case "showRenderTime":
                        displayMessage("RenderTime: " + this._lastRenderTime + "ms");
                        applyColor(dataField);
                        break;
                     case DATA_SEPARATOR:
                        addSeparator(dataField);
                        break;
                     case DATA_EMPTY_SPACE:
                        addEmptySpace(dataField);
                        break;
                     case DATA_TEXT:
                        addCustomText(dataField);
                        break;
                     case DATA_GROUP:
                        if(parts.length > 1)
                        {
                           displayGroup(parts[1]);
                        }
                        break;
                  }
                  d++;
               }
            }
            drawBackground();
            drawSeparators();
            this._lastRenderTime = getTimer() - t1;
         }
         catch(error:Error)
         {
            displayMessage("Error displaying players: " + error);
            drawBackground();
         }
      }
      
      public function getPlayers() : Array
      {
         var existingPlayers:Object = {};
         if(!this.AccountInfoData.data || !this.CharacterInfoData.data)
         {
            return;
         }
         this._textChatUsers = this.getTextChatUserList();
         var players:Array = [];
         var playerName:String = "";
         var _campMarkers:* = {};
         if(this.MapMenuData && this.MapMenuData.data && this.MapMenuData.data.MarkerData)
         {
            for each(marker in this.MapMenuData.data.MarkerData)
            {
               if(marker.playerLevel > 0)
               {
                  playerName = marker.text.split(TITLE_DELIMITER)[0];
                  if(existingPlayers[playerName] != null)
                  {
                     var currentPlayer:Object = players[existingPlayers[playerName]];
                     currentPlayer.type = marker.markerType;
                     currentPlayer.level = marker.playerLevel;
                     currentPlayer.bounty = marker.bounty;
                     currentPlayer.isFriend = marker.isFriend;
                     currentPlayer.isTextChatUser = playerName.length > 0 ? isTextChatUser(playerName) : false;
                     currentPlayer.x = marker.x;
                     currentPlayer.y = marker.y;
                  }
                  else
                  {
                     players.push({
                        "name":playerName,
                        "type":marker.markerType,
                        "level":marker.playerLevel,
                        "bounty":marker.bounty,
                        "isFriend":marker.isFriend,
                        "isTextChatUser":(playerName.length > 0 ? isTextChatUser(playerName) : false),
                        "x":marker.x,
                        "y":marker.y
                     });
                     existingPlayers[playerName] = players.length - 1;
                  }
                  lastLevelData[playerName] = marker.playerLevel;
               }
               else if(marker.owningPlayerName && marker.markerType == CAMP_MARKER)
               {
                  if(!marker.isLocalPlayersCamp)
                  {
                     playerName = marker.owningPlayerName.split(TITLE_DELIMITER)[0];
                     if(existingPlayers[playerName] == null)
                     {
                        players.push({
                           "name":playerName,
                           "type":IS_HIDDEN,
                           "level":lastLevelData[playerName] || 0,
                           "bounty":0,
                           "isTextChatUser":(playerName.length > 0 ? isTextChatUser(playerName) : false)
                        });
                        existingPlayers[playerName] = players.length - 1;
                     }
                     if(marker.isVending)
                     {
                        _campMarkers[playerName] = {
                           "markerId":marker.markerID,
                           "x":marker.x,
                           "y":marker.y
                        };
                     }
                  }
               }
               else if(marker.markerType == PLAYER_LOCAL)
               {
                  players.push({
                     "name":this.AccountInfoData.data.name,
                     "type":marker.markerType,
                     "level":this.CharacterInfoData.data.level,
                     "bounty":this.CharacterInfoData.data.bounty,
                     "x":marker.x,
                     "y":marker.y
                  });
                  playerPosition = {
                     "x":marker.x,
                     "y":marker.y
                  };
                  existingPlayers[this.AccountInfoData.data.name] = players.length - 1;
               }
            }
         }
         this.campMarkers = _campMarkers;
         if(this.PublicTeamsData && this.PublicTeamsData.data && this.PublicTeamsData.data.publicTeams)
         {
            for each(team in this.PublicTeamsData.data.publicTeams)
            {
               for each(member in team.members)
               {
                  if(member.playerName.length > 0)
                  {
                     if(existingPlayers[member.playerName] == null)
                     {
                        players.push({
                           "name":member.playerName,
                           "type":IS_HIDDEN,
                           "level":member.playerLvl,
                           "bounty":0,
                           "isTextChatUser":(member.playerName.length > 0 ? isTextChatUser(member.playerName) : false)
                        });
                        lastLevelData[member.playerName] = member.playerLvl;
                        existingPlayers[member.playerName] = players.length - 1;
                     }
                  }
               }
            }
         }
         _playerCount = players.length;
         return players;
      }
      
      public function isTextChatUser(name:String) : Boolean
      {
         if(name == this.AccountInfoData.data.name || !this._textChatUsers)
         {
            return false;
         }
         return this._textChatUsers.indexOf(name) != -1;
      }
      
      public function isValidPlayerToShow(player:Object) : Boolean
      {
         if(!player)
         {
            return false;
         }
         var indexType:int = int(ArrayUtils.indexOfCaseInsensitiveString(config.hideTypes,player.type));
         if(indexType != -1)
         {
            return false;
         }
         var index:int = int(ArrayUtils.indexOfCaseInsensitiveString(config.hidePlayers,player.name));
         return index == -1;
      }
      
      public function getTextChat() : void
      {
         if(!this.isHudMenu || !this.topLevel)
         {
            return;
         }
         var i:int = this.topLevel.numChildren - 1;
         while(i >= 0)
         {
            if(getQualifiedClassName(this.topLevel.getChildAt(i)) == TITLE_LOADER)
            {
               if(getQualifiedClassName(this.topLevel.getChildAt(i).content) == TITLE_TEXTCHAT)
               {
                  this.textChat = this.topLevel.getChildAt(i).content;
                  break;
               }
            }
            i--;
         }
      }
      
      public function getTextChatUserList() : Array
      {
         if(!this.textChat)
         {
            this.getTextChat();
         }
         if(this.textChat && this.textChat.TextChatBase_mc && this.textChat.TextChatBase_mc.UserList_mc && this.textChat.TextChatBase_mc.UserList_mc.UserList && this.textChat.TextChatBase_mc.UserList_mc.UserList.UserListArray)
         {
            return this.textChat.TextChatBase_mc.UserList_mc.UserList.UserListArray;
         }
         return [];
      }
      
      public function isValidHUDMode() : Boolean
      {
         if(config)
         {
            if(config.HUDModesState == HUDPlayerListConfig.STATE_HIDDEN)
            {
               return this.isInMainMenu ? config.HUDModes.indexOf(MAIN_MENU) == -1 : config.HUDModes.indexOf(this.HUDModeData.data.hudMode) == -1;
            }
            return this.isInMainMenu ? config.HUDModes.indexOf(MAIN_MENU) != -1 : config.HUDModes.indexOf(this.HUDModeData.data.hudMode) != -1;
         }
         return true;
      }
   }
}

