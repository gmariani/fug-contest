package cv {
	
	import cv.orion.ParticleVO;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.filters.BlurFilter;
	import flash.display.BitmapData;

	public final class OrionPixelCustom {
		
		private const _pt:Point = new Point();
		private const _ftrBlur:BlurFilter = new BlurFilter(10, 10);
		
		private var _particles:ParticleVO;
		private var _bmpd1:BitmapData;
		private var _bmpd2:BitmapData;
		private var _bmpdOverlay:BitmapData;
		private var _root:MovieClip;
		
		public function OrionPixelCustom(bmpd1:BitmapData, bmpd2:BitmapData, bmpdSource:BitmapData, root:MovieClip) {
			_bmpd1 = bmpd1;
			_bmpd2 = bmpd2;
			_root = root;
			_root.addEventListener(Event.ENTER_FRAME, render, false, 0, true);
			_bmpdOverlay = new BitmapData(700, 450, true, 0);
			_bmpdOverlay.fillRect(_bmpdOverlay.rect, 0x10000000);
			
			// Create Particles
			var currentParticle:ParticleVO = _particles = new ParticleVO();
			var yy:int = bmpdSource.height;
			var xx:int;
			var c:int;
			while (--yy > -1) {
				xx = bmpdSource.width;
				while (--xx > -1) {
					c = bmpdSource.getPixel32(xx, yy);
					if(c) {
						currentParticle = currentParticle.next = new ParticleVO();
						currentParticle.originX = currentParticle.x = xx + 186.5;
						currentParticle.originY = currentParticle.y = yy;
						currentParticle.color = c;
					}
				}
			}
		}
		
		private function render(e:Event):void {
			var particle:ParticleVO = _particles;
			var dx:int;
			var dy:int;
			var min:int;
			var max:int;
			var mox:int;
			var moy:int;
			var tot:Number;
			var sqNum:Number;
			var apprxInit:int;
			var apprxRoot:Number;
			//var initVal:Number;
			var mx:Number = _root.mouseX;
			var my:Number = _root.mouseY;
			
			_bmpd1.lock();
			_bmpd2.lock();
			
			_bmpd1.copyPixels(_bmpdOverlay, _bmpdOverlay.rect, _pt, null, null, true);
			_bmpd1.applyFilter(_bmpd1, _bmpd1.rect, _pt, _ftrBlur);
			
			_bmpd2.copyPixels(_bmpdOverlay, _bmpdOverlay.rect, _pt, null, null, true);
			
			do {
				// Apply Filter
				dx = particle.originX - particle.x;
				dy = particle.originY - particle.y;
				
				mox = mx - particle.x;
				moy = my - particle.y;
				
				//mrad = Math.sqrt(mox * mox + moy * moy);
				if (mox < 0) mox = -mox;
				if (moy < 0) moy = -moy;
				if (mox < moy)  {
					min = mox;
					max = moy;
				} else {
					min = moy;
					max = mox;
				}
				apprxRoot = ((( max << 8 ) + ( max << 3 ) - ( max << 4 ) - ( max << 1 ) + ( min << 7 ) - ( min << 5 ) + ( min << 3 ) - ( min << 1 )) >> 8 );
				/*apprxRoot = sqNum = mox * mox + moy * moy;
				if(sqNum != 0) {
					/*if (sqNum < 1) {
						initVal = 1 / sqNum;
					} else {
						initVal = sqNum;
					}
					apprxInit = initVal;/
					apprxInit = sqNum;
					
					if (apprxInit > 7) {
						if (apprxInit < 32768) {
							if (apprxInit < 128) {
								if (apprxInit < 32) {
									apprxInit >>= 2;
									if (apprxInit < 4) apprxInit++;
								} else {
									apprxInit >>= 3;
								}
							} else {
								if (apprxInit < 2048) {
									if (apprxInit < 512) {
										apprxInit >>= 4;
									} else {
										apprxInit >>= 5;
									}
								} else {
									if (apprxInit < 8096) {
										apprxInit >>= 6;
									} else {
										apprxInit >>= 7;
									}
								}
							}
						} else {
							if (apprxInit < 8388608) {
								if (apprxInit < 524288) {
									if (apprxInit < 131072) {
										apprxInit >>= 8;
									} else {
										apprxInit >>= 9;
									}
								} else {
									if (apprxInit < 2097152) {
										apprxInit >>= 10;
									} else {
										apprxInit >>= 11;
									}
								}
							} else {
								if (apprxInit < 134217728) {
									if (apprxInit < 33554432) {
										apprxInit >>= 12;
									} else {
										apprxInit >>= 13;
									}
								} else {
									apprxInit >>= 14;		//What are you doing with a number this big anyway?  Not bothering with yet another test.
								}
							}
						}
						apprxRoot = (apprxInit + sqNum / apprxInit) * 0.5;
					} else if (apprxInit < 2) {
						apprxRoot = sqNum * 0.5 + 0.5;
					} else {
						apprxRoot = sqNum * 0.25 + 1;
					}
					//if (sqNum < 1)  apprxRoot = 1 / apprxRoot; // Doesn't seem to ever be below 0
				}
				// end sqrt
				*/
				if (apprxRoot + Math.random() * apprxRoot < 100) {
					if (apprxRoot != 0) {
						particle.lifeTime = 1;
						particle.velocityX += mox / apprxRoot;
						particle.velocityY += moy / apprxRoot;
					}
				} else {
					//rad = Math.sqrt(dx * dx + dy * dy);
					if (dx < 0) dx = -dx;
					if (dy < 0) dy = -dy;
					if (dx < dy)  {
						min = dx;
						max = dy;
					} else {
						min = dy;
						max = dx;
					}
					apprxRoot = ((( max << 8 ) + ( max << 3 ) - ( max << 4 ) - ( max << 1 ) + ( min << 7 ) - ( min << 5 ) + ( min << 3 ) - ( min << 1 )) >> 8 );
					/*sqNum = dx * dx + dy * dy;
					if(sqNum != 0) {
						/*if (sqNum < 1) {
							initVal = 1 / sqNum;
						} else {
							initVal = sqNum;
						}
						apprxInit = initVal;/
						apprxInit = sqNum;
						
						if (apprxInit > 7) {
							if (apprxInit < 32768) {
								if (apprxInit < 128) {
									if (apprxInit < 32) {
										apprxInit >>= 2;
										if (apprxInit < 4) apprxInit++;
									} else {
										apprxInit >>= 3;
									}
								} else {
									if (apprxInit < 2048) {
										if (apprxInit < 512) {
											apprxInit >>= 4;
										} else {
											apprxInit >>= 5;
										}
									} else {
										if (apprxInit < 8096) {
											apprxInit >>= 6;
										} else {
											apprxInit >>= 7;
										}
									}
								}
							} else {
								if (apprxInit < 8388608) {
									if (apprxInit < 524288) {
										if (apprxInit < 131072) {
											apprxInit >>= 8;
										} else {
											apprxInit >>= 9;
										}
									} else {
										if (apprxInit < 2097152) {
											apprxInit >>= 10;
										} else {
											apprxInit >>= 11;
										}
									}
								} else {
									if (apprxInit < 134217728) {
										if (apprxInit < 33554432) {
											apprxInit >>= 12;
										} else {
											apprxInit >>= 13;
										}
									} else {
										apprxInit >>= 14;		//What are you doing with a number this big anyway?  Not bothering with yet another test.
									}
								}
							}
							apprxRoot = (apprxInit + sqNum / apprxInit) * 0.5;
						} else if (apprxInit < 2) {
							apprxRoot = sqNum * 0.5 + 0.5;
						} else {
							apprxRoot = sqNum * 0.25 + 1;
						}
						//if (sqNum < 1) apprxRoot = 1 / apprxRoot; // Doesn't seem to ever be below 0
						// end sqrt
						*/
						if (apprxRoot != 0) {
							particle.velocityX += dx / apprxRoot;
							particle.velocityY += dy / apprxRoot;
						}
					//}
				}
				
				particle.velocityX *= particle.lifeTime;
				particle.velocityY *= particle.lifeTime;
				particle.lifeTime *= 0.998;
				
				tot = 0;
				tot += particle.velocityX < 0 ? -particle.velocityX : particle.velocityX; // Math.abs
				tot += particle.velocityY < 0 ? -particle.velocityY : particle.velocityY; // Math.abs
				tot += dx < 0 ? -dx : dx; // Math.abs
				tot += dy < 0 ? -dy : dy; // Math.abs
				if (tot < 5) {
					particle.lifeTime -= .1;
					if (tot < 1) {
						particle.x = particle.originX;
						particle.y = particle.originY;
						particle.velocityX = 0;
						particle.velocityY = 0;
					}
				}
				if (particle.lifeTime < .1) particle.lifeTime = .1;
				
				// Position particle
				if (particle.velocityX != 0) particle.x += particle.velocityX;
				if (particle.velocityY != 0) particle.y += particle.velocityY;
				
				// Draw
				_bmpd2.setPixel32(particle.x, particle.y, particle.color);
				
				particle = particle.next;
			} while (particle);
			
			_bmpd1.copyPixels(_bmpd2, _bmpd2.rect, _pt, null, null, true);
			
			_bmpd1.unlock();
			_bmpd2.unlock();
		}
	}
}