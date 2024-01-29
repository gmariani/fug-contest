/**
* Orion ©2009 Gabriel Mariani. February 9th, 2009
* Visit http://blog.coursevector.com/orion for documentation, updates and more free code.
*
*
* Copyright (c) 2009 Gabriel Mariani
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

// TweenLite helped too
// BetweenAS3 helped too
// http://blog.joa-ebert.com/2009/04/03/massive-amounts-of-3d-particles-without-alchemy-and-pixelbender/

package cv {
	
	import cv.orion.Orion;
	import cv.orion.interfaces.IFilter;
	import cv.orion.interfaces.IOutput;
	import cv.orion.ParticleVO;
	import cv.orion.events.ParticleEvent;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * <strong>Orion ©2009 Gabriel Mariani, coursevector.com.
	 * <br/>Visit http://blog.coursevector.com/orion for documentation, updates and more 
	 * free code.
	 * <br/>Licensed under the MIT license - see the source file header 
	 * for more information.</strong>
	 * <hr>
	 * Orion is an easy to use and light-weight particle system. It's instance 
	 * oriented much like GTween so you can re-use and modify easily. It's 
	 * also very fast, capable of handling over 3000 particles at more than 
	 * 30fps if your computer can handle it. But unless you're doing something 
	 * really intense you probably won't notice any slowdown. At it's smallest
	 * Orion will add about 6kb to your filesize.
	 * <br/><br/>
	 * The Orion class is the hub of particle system. It  
	 * determines <strong>where</strong> the particles will be generated.
	 * All particles are generated within the bounds of the Orion instance.
	 * So if you set it up to be 100x100, the particles will be generated 
	 * somewhere within that area. If you set the width and height below
	 * 1 (i.e. 0x0), it will generate all the particles at the center of the 
	 * instance.
	 * <br/><br/>
	 * To control where the particles can be displayed you can modify the 
	 * canvas property. The canvas is a simple rectange object, changing the
	 * height, width, and position of it will determine where the particles 
	 * will be displayed and when the edgeFilter will take action.
	 * <br/><br/>
	 * Orion is easy to use and incredibly flexible and customizable. To keep 
	 * it's size down, there are effectFilters, the more you add the more work 
	 * Orion has to do which can affect performance and filesize. So keep this 
	 * in mind before you use every filter and wonder why it's not handling 
	 * 3000 particles easily. Below are some examples to show you how to use 
	 * Orion and how quickly you can get up and running. Since Orion is so 
	 * customizable, I thought it would be nice to be able to save those 
	 * configurations so you can use the same settings again. This is what the 
	 * presets are used for. They will configure an instance of Orion with the 
	 * given settings. If you have to find a setting you like you can create 
	 * your own presets and load them as well.
	 * 
	 * @example The only requirement to use Orion is to have an item exported from the library.
	 * <br/><br/>
	 * <listing version="3.0">
	 * import cv.orion.Orion;
	 * import cv.orion.preset.Default; // A small set of common presets
	 * 
	 * var e:Orion = new Orion(linkageClass, null, Default.firework());
	 * this.addChild(e);
	 * 
	 * </listing>
	 * <br/><br/>
	 * That's it! Although that is a very basic setup but as you can see, it doesn't take much work to get a particle
	 * system up and running in your code.
     */
	public class OrionPixelCustom extends Orion implements IOutput {
		
		protected var _bmpd1:BitmapData;
		protected var _bmpd2:BitmapData;
		protected var _overlay:MovieClip;
		protected var _ftrBlur:BlurFilter = new BlurFilter(10, 10);
		protected const POINT:Point = new Point(0, 0);
		
		/**
		 * The constructor allows a few common settings to be specified during construction. Options such
		 * as the output class or any configuration settings.
		 * 
		 * @param	spriteClass This is the linkage class of the item you have exported from the library.
		 * @param	output	Here you can specify which output class you'd like to use. If you don't want to 
		 * use one, just leave this as <code>null</code>
		 * @param	config	Here you can pass in a <code>configuration</code> object. A <code>configuration</code> object is generated by a 
		 * preset or you can write one by hand. Each <code>configuration</code> object can contain an <code>effectFilters</code> vector, an
		 * <code>edgeFilter</code> object, and a <code>settings</code> object. The <code>settings</code> object can contain all the same properties that
		 * modifying the <code>settings</code> property directly allows.
		 * @param	useFrameCaching	Frame caching is useful for particles that have a lot of glow filters or native Flash filters applied.
		 * Turning on frame caching will cause Orion to take a snapshot of each frame of the particle and turn it into a Bitmap and use the Bitmap
		 * instead. This can greatly increase performance for complicated particles.
		 * 
		 * @see Orion#settings
		 * @see Orion#useFrameCaching
		 */
		public function OrionPixelCustom(bmpd1:BitmapData, bmpd2:BitmapData, bmpdSource:BitmapData, overlay:MovieClip, config:Object = null) {
			_bmpd1 = bmpd1;
			_bmpd2 = bmpd2;
			_overlay = overlay;
			super(config);
			
			// Create Particles
			var numParticles:int = bmpdSource.width * bmpdSource.height - 1;
			_particles = createParticle(numParticles);
			var currentParticle:ParticleVO = _particles;
			var i:int = numParticles;
			var offsetX:int = 225;
			var offsetY:int = 0;
			for (var yy:int = 0; yy < bmpdSource.height; yy++) {
				for (var xx:int = 0; xx < bmpdSource.width; xx++) {
					if(bmpdSource.getPixel32(xx, yy)) {
						currentParticle = currentParticle.next = createParticle(i);
						currentParticle.active = true;
						currentParticle.mass = 0.95;
						currentParticle.originX = currentParticle.x = xx + offsetX;
						currentParticle.originY = currentParticle.y = yy + offsetY;
						currentParticle.originZ = currentParticle.z = bmpdSource.getPixel32(xx, yy);
					}
					--i;
				}
			}
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Updates all the particles and positions, updates the output class as well.
		 * 
		 * @param	e The event dispatched.
		 * @default null
		 */
		override public function render(e:Event = null):void {
			if (paused) return;
			
			// Variables used in the loop
			var particle:ParticleVO = _particles;
			var length:uint = 0;
			var effectFiltersLength:uint = effectFilters.length;
			var _effectFilters:Array = effectFilters;
			var x:Number;
			var y:Number;
			var i:uint;
			
			var dx:int;
			var dy:int;
			var mox:int;
			var moy:int;
			var mrad:Number;
			var rad:Number;
			var tot:Number;
			
			_bmpd1.lock();
			_bmpd2.lock();
			
			_bmpd1.draw(_overlay);
			_bmpd1.applyFilter(_bmpd1, _bmpd1.rect, POINT, _ftrBlur);
			
			_bmpd2.draw(_overlay);
			
			do {
				if(particle.active) {
					// Count particles
					++length;
					
					// Apply Filters
					/*i = effectFiltersLength;
					while (--i > -1) {
						_effectFilters[i].applyFilter(particle, this);
					}*/
					// Put inline for speed
					// mass is being used as a lifeTime
					dx = particle.originX - particle.x;
					dy = particle.originY - particle.y;
					
					mox = this.mouseX - particle.x;
					moy = this.mouseY - particle.y;
					
					mrad = Math.sqrt(mox * mox + moy * moy);
					if (mrad + Math.random() * mrad < 100) {
						if (mrad != 0) {
							particle.mass = 1;
							particle.velocityX += mox / mrad;
							particle.velocityY += moy / mrad;
						}
					} else {
						rad = Math.sqrt(dx * dx + dy * dy);
						if (rad != 0) {
							particle.velocityX += dx / rad;
							particle.velocityY += dy / rad;
						}
					}
					
					particle.velocityX *= particle.mass;
					particle.velocityY *= particle.mass;
					particle.mass *= 0.998;
					
					tot = abs(particle.velocityX) + abs(particle.velocityY) + abs(dx) + abs(dy);
					if (tot < 5) {
						particle.mass -= .1;
						if (tot < 1) {
							particle.x = particle.originX;
							particle.y = particle.originY;
							particle.velocityX = 0;
							particle.velocityY = 0;
						}
					}
					if (particle.mass < .1) particle.mass = .1;
					////////////////////////////
					
					// Position particle
					if (particle.velocityX != 0) particle.x += particle.velocityX;
					if (particle.velocityY != 0) particle.y += particle.velocityY;
					
					// Draw
					_bmpd2.setPixel32(particle.x, particle.y, particle.z);
				}
				
				particle = particle.next;
			} while (particle);	
			
			_numParticles = length;
			
			/*
			BlendMode.ADD,
			BlendMode.ALPHA,
			BlendMode.DARKEN,
			BlendMode.DIFFERENCE,
			BlendMode.ERASE,
			BlendMode.HARDLIGHT,
			BlendMode.INVERT,
			BlendMode.LAYER,
			BlendMode.LIGHTEN,
			BlendMode.MULTIPLY,
			BlendMode.NORMAL,
			BlendMode.OVERLAY,
			BlendMode.SCREEN,
			BlendMode.SUBTRACT
			*/
			_bmpd1.draw(_bmpd2, null, null, BlendMode.LIGHTEN);
			_bmpd1.draw(_bmpd2);
			
			_bmpd1.unlock();
			_bmpd2.unlock();
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function abs(value:Number):Number {
			if (value < 0) value = -value;
			return value;
		}
		
		override protected function addParticle(p:ParticleVO, pt:Point = null):Boolean {
			var pt:Point = pt || getCoordinate();
			if (pt) {
				_mtx.tx = pt.x;
				_mtx.ty = pt.y;
				
				p.active = true;
				p.paused = false;
				p.timeStamp = Orion.time;
				p.mass = settings.mass;
				
				if(settings.velocityXMin != settings.velocityXMax) {
					p.velocityX = randomRange(settings.velocityXMin, settings.velocityXMax);
				} else {
					p.velocityX = settings.velocityX;
				}
				
				if(settings.velocityYMin != settings.velocityYMax) {
					p.velocityY = randomRange(settings.velocityYMin, settings.velocityYMax);
				} else {
					p.velocityY = settings.velocityY;
				}
				
				p.x = _mtx.tx;
				p.y = _mtx.ty;
				
				return true;
			}
			return false;
		}
	}
}