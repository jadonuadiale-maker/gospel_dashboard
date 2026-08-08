// services/dsp_gain.dart
class DspGain {
  final double gain; // e.g. 1.2 = +20%

  DspGain(this.gain);

  /// Applies gain with soft clipping.
  double process(double sample) {
    double boosted = sample * gain;

    // Soft clip curve
    if (boosted > 1.0) boosted = 1.0 - (boosted - 1.0) * 0.5;
    if (boosted < -1.0) boosted = -1.0 + (boosted + 1.0) * 0.5;

    return boosted;
  }
}