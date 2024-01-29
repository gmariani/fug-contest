package cv.orion {

	public final class ParticleVO {
		public var next:ParticleVO;
		public var color:int = 0;
		public var color2:int = 0;
		public var colorPercent:Number = 1;
		
		public var a:int = 0;
		public var r:int = 0;
		public var g:int = 0;
		public var b:int = 0;
		
		public var a2:int = 0;
		public var r2:int = 0;
		public var g2:int = 0;
		public var b2:int = 0;
		
		public var lifeTime:Number = 0.95;
		
		public var velocityX:Number = 0.0;
		public var velocityY:Number = 0.0;
		
		public var originX:Number = 0.0;
		public var originY:Number = 0.0;
		
		public var x:Number = 0.0;
		public var y:Number = 0.0;
	}
}