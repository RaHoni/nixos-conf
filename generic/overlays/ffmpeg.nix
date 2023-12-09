(final: prev: {
  ffmpeg-qsv = prev.ffmpeg.override { withVpl = true; withMfx = false; };
})
