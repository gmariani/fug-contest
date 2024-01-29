package {
	
	import cv.orion.ParticleVO;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import net.hires.debug.Stats;
	
	public final class FUGContest extends MovieClip {
		
		private const _bmpd1:BitmapData = new BitmapData(700, 450, true, 0);
		private const _bmpd2:BitmapData = new BitmapData(700, 450, true, 0);
		private const _bmpdOverlay:BitmapData = new BitmapData(700, 450, true, 0);
		private const _pt:Point = new Point();
		private const _ftrBlur:BlurFilter = new BlurFilter(30, 30);
		private const _images:Array = [
			//new heart(0,0) as BitmapData,
			new Design1Smaller(0, 0) as BitmapData,
			new Design2Smaller(0, 0) as BitmapData,
			new Design3Smaller(0, 0) as BitmapData,
			new Design4Smaller(0, 0) as BitmapData,
			new Design5Smaller(0, 0) as BitmapData
		];
		
		private var _bmpdSource:BitmapData;
		private var _imageIndex:int = 0;
		private var _particles:ParticleVO;
		
		public function FUGContest() {
			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			
			addChild(new Bitmap(_bmpd1, PixelSnapping.NEVER, false));
			
			var bmp2:Bitmap = new Bitmap(_bmpd2, PixelSnapping.NEVER, false);
			bmp2.blendMode = BlendMode.MULTIPLY;
			addChild(bmp2);
			addChild(new Stats());
			
			_bmpdOverlay.fillRect(_bmpdOverlay.rect, 0x10000000);
			
			// Create Particles
			_bmpdSource = _images[_imageIndex];
			var currentParticle:ParticleVO = _particles = new ParticleVO();
			var yy:int = _bmpdSource.height;
			var xx:int;
			var c:int;
			while (--yy > -1) {
				xx = _bmpdSource.width;
				while (--xx > -1) {
					c = _bmpdSource.getPixel32(xx, yy);
					if(c) {
						currentParticle = currentParticle.next = new ParticleVO();
						currentParticle.originX = currentParticle.x = xx + 186.5;
						currentParticle.originY = currentParticle.y = yy;
						currentParticle.color = currentParticle.color2 = c;
						
						currentParticle.a = (c >> 24) & 0xFF;
						currentParticle.r = (c >> 16) & 0xFF;
						currentParticle.g = (c >> 8) & 0xFF;
						currentParticle.b = c & 0xFF;
					}
				}
			}
			
			var tf:TextFormat = new TextFormat();
			tf.font = 'arial';
			tf.size = 10;
			tf.color = 0xFFFFFF;
			
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = tf;
			textField.selectable = false;
			textField.text = 'FUG Contest : Pushing ' + (_bmpdSource.height * _bmpdSource.width) + ' particles (pure ActionScript 3).';
			textField.y = 450 - textField.height;
			textField.opaqueBackground = 0x000000;
			addChild(textField);
			
			this.addEventListener(Event.ENTER_FRAME, render, false, 0, true);
		}
		
		private function clickHandler(e:MouseEvent):void {
			this.removeEventListener(Event.ENTER_FRAME, render);
			
			_imageIndex++;
			_imageIndex %= 5;
			
			_bmpdSource = _images[_imageIndex];
			var currentParticle:ParticleVO = _particles;
			var yy:int = _bmpdSource.height;
			var xx:int;
			var c:int;
			while (--yy > -1) {
				xx = _bmpdSource.width;
				while (--xx > -1) {
					c = _bmpdSource.getPixel32(xx, yy);
					if (c) {
						currentParticle.color2 = c;
						currentParticle.a2 = ((c >> 24) & 0xFF) - currentParticle.a;
						currentParticle.r2 = ((c >> 16) & 0xFF) - currentParticle.r;
						currentParticle.g2 = ((c >>  8) & 0xFF) - currentParticle.g;
						currentParticle.b2 = (c & 0xFF) - currentParticle.b;
						currentParticle.colorPercent = 0;
						currentParticle = currentParticle.next;
					}
				}
			}
			
			this.addEventListener(Event.ENTER_FRAME, render, false, 0, true);
		}
		
		private function render(e:Event):void {
			var particle:ParticleVO = _particles;
			var dx:int;
			var dy:int;
			var mox:int;
			var moy:int;
			var tot:Number;
			var sqNum:Number;
			var apprxInit:int;
			var apprxRoot:Number;
			//var initVal:Number;
			var mx:Number = this.mouseX;
			var my:Number = this.mouseY;
			
			_bmpd1.lock();
			_bmpd2.lock();
			
			// Resets the bitmap
			_bmpd2.copyPixels(_bmpdOverlay, _bmpdOverlay.rect, _pt, null, null, true);
			
			do {
				// Apply Filter
				dx = particle.originX - particle.x;
				dy = particle.originY - particle.y;
				
				mox = mx - particle.x;
				moy = my - particle.y;
				
				//mrad = Math.sqrt(mox * mox + moy * moy);
				apprxRoot = sqNum = mox * mox + moy * moy;
				if(sqNum != 0) {
					/*if (sqNum < 1) {
						initVal = 1 / sqNum;
					} else {
						initVal = sqNum;
					}
					apprxInit = initVal;*/
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
							//if (apprxInit < 8388608) {
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
							/*} else {
								if (apprxInit < 134217728) {
									if (apprxInit < 33554432) {
										apprxInit >>= 12;
									} else {
										apprxInit >>= 13;
									}
								} else {
									apprxInit >>= 14;		//What are you doing with a number this big anyway?  Not bothering with yet another test.
								}
							}*/
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
				
				if (apprxRoot + Math.random() * apprxRoot < 100) {
					if (apprxRoot != 0) {
						particle.lifeTime = 1;
						particle.velocityX += mox / apprxRoot;
						particle.velocityY += moy / apprxRoot;
					}
				} else {
					//rad = Math.sqrt(dx * dx + dy * dy);
					sqNum = dx * dx + dy * dy;
					if(sqNum != 0) {
						/*if (sqNum < 1) {
							initVal = 1 / sqNum;
						} else {
							initVal = sqNum;
						}
						apprxInit = initVal;*/
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
								//if (apprxInit < 8388608) {
									//if (apprxInit < 524288) {
										if (apprxInit < 131072) {
											apprxInit >>= 8;
										} else {
											apprxInit >>= 9;
										}
									/*} else {
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
								}*/
							}
							apprxRoot = (apprxInit + sqNum / apprxInit) * 0.5;
						} else if (apprxInit < 2) {
							apprxRoot = sqNum * 0.5 + 0.5;
						} else {
							apprxRoot = sqNum * 0.25 + 1;
						}
						//if (sqNum < 1) apprxRoot = 1 / apprxRoot; // Doesn't seem to ever be below 0
						// end sqrt
						
						if (apprxRoot != 0) {
							particle.velocityX += dx / apprxRoot;
							particle.velocityY += dy / apprxRoot;
						}
					}
				}
				
				particle.velocityX *= particle.lifeTime;
				particle.velocityY *= particle.lifeTime;
				particle.lifeTime *= 0.998;
				
				if (dx < 0) dx = -dx;
				if (dy < 0) dy = -dy;
				tot = 0 + dx + dy;
				tot += particle.velocityX < 0 ? -particle.velocityX : particle.velocityX; // Math.abs
				tot += particle.velocityY < 0 ? -particle.velocityY : particle.velocityY; // Math.abs
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
				
				// Color Particle
				if(particle.color != particle.color2) {
					if(particle.colorPercent < 1) {
						particle.color = (particle.a + (particle.colorPercent * particle.a2)) << 24 | (particle.r + (particle.colorPercent * particle.r2)) << 16 | (particle.g + (particle.colorPercent * particle.g2)) << 8 | (particle.b + (particle.colorPercent * particle.b2));
						particle.colorPercent += 0.05;
					} else {
						particle.color = particle.color2;
						particle.a = (particle.color >> 24) & 0xFF;
						particle.r = (particle.color >> 16) & 0xFF;
						particle.g = (particle.color >> 8) & 0xFF;
						particle.b = particle.color & 0xFF;
						particle.colorPercent = 1;
					}
				}
				
				// Position Particle
				if (particle.velocityX != 0) particle.x += particle.velocityX;
				if (particle.velocityY != 0) particle.y += particle.velocityY;
				
				// Draw
				_bmpd2.setPixel32(particle.x, particle.y, particle.color);
				
				particle = particle.next;
			} while (particle);
			
			_bmpd1.copyPixels(_bmpd2, _bmpd2.rect, _pt, null, null, true);
			_bmpd1.applyFilter(_bmpd1, _bmpd1.rect, _pt, _ftrBlur);
			_bmpd1.unlock();
			_bmpd2.unlock();
		}
	}
}