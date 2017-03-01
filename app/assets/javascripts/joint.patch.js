// fix bug in old JointJS v0.9.0 without updating it as an update would require jQuery 2.1.3+
// see https://github.com/clientIO/joint/issues/203
SVGElement.prototype.getTransformToElement = SVGElement.prototype.getTransformToElement || function(toElement) {
  return toElement.getScreenCTM().inverse().multiply(this.getScreenCTM());
};
