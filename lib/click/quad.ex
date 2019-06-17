defmodule Click.Quad do
  def center([ul_x, ul_y, ur_x, _ur_y, _ll_x, ll_y, _lr_x, _lr_y]) do
    width = ur_x - ul_x
    height = ll_y - ul_y
    [ul_x + width / 2, ul_y + height / 2]
  end
end
