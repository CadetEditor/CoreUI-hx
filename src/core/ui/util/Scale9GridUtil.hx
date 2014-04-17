package core.ui.util;

import core.ui.util.Rectangle;
import core.ui.util.Sprite;
import nme.errors.Error;
import nme.display.Sprite;import nme.geom.Rectangle;class Scale9GridUtil
{public static function setScale9Grid(skin : Sprite, grid : Rectangle) : Void{while (!skin.scale9Grid){try{skin.scale9Grid = grid;
            }            catch (e : Error){  //trace("setScale9Grid "+e.errorID+" "+e.message);  
            }
        }
    }

    public function new()
    {
    }
}