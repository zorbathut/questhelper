
#include <Magick++.h>

#include <string>

using namespace Magick;

using namespace std;

void drawCapsule(const string &text, float sx, float sy, float ex, float ey, float fill, int screenwidth, int screenheight, string outname) {
  Image img(Geometry(screenwidth, screenheight), Color(247 * 256, 247 * 256, 247 * 256));
  
  float height = ey - sy;
  float width = ex - sx;
  
  img.strokeWidth(15);
  img.strokeAntiAlias(true);
  img.strokeColor("black");
  img.fillColor("transparent");
  
  img.strokeColor("transparent");
  img.fillColor(Color(MaxRGB * 0.2, 0, MaxRGB * 0.9, 0));
  
  img.draw(DrawableArc(sx, sy, sx + height, ey, 90, 270));
  img.draw(DrawableArc(ex - height, sy, ex, ey, 270, 90));
  img.draw(DrawableRectangle(sx + height / 2, sy, ex - height / 2, ey));
  
  img.fillColor("white");
  img.draw(DrawableRectangle(sx + width * fill, sy, ex, ey));
  
  img.strokeColor("black");
  img.fillColor("transparent");
  
  img.draw(DrawableArc(sx, sy, sx + height, ey, 90, 270));
  img.draw(DrawableArc(ex - height, sy, ex, ey, 270, 90));
  img.draw(DrawableLine(sx + height / 2, sy, ex - height / 2, sy));
  img.draw(DrawableLine(sx + height / 2, ey, ex - height / 2, ey));
  
  for(int i = 1; i < 10; i++)
    img.draw(DrawableLine(sx + width / 10 * i, sy, sx + width / 10 * i, sy + height / 10));
  
  img.strokeColor("gray80");
  img.draw(DrawableLine(sx + height * 0.6, sy + height * 0.3, ex - height * 0.4, sy + height * 0.3));
  
  img.strokeColor("transparent");
  img.fillColor("black");
  
  /*
  list<Drawable> wut;
  //img.draw(DrawableFont("Arial"));
  wut.push_back(DrawableFont("tahoma.ttf"));
  wut.push_back(DrawablePointSize(110));
  wut.push_back(DrawableGravity(WestGravity));
  wut.push_back(DrawableText(20, 0, text));
  img.draw(wut);*/
  
  img.zoom(Geometry(screenwidth / 10, screenheight / 10));
  
  Image teximg;
  teximg.read("text_" + outname);
  img.composite(teximg, WestGravity, OverCompositeOp);
  
  Image timg;
  timg.read("cont.png");
  img.composite(timg, EastGravity, OverCompositeOp);
  
  img.write(outname);
}

int main() {
  const int dimx = 6800;
  const int dimy = 300;
  
  const int xstart = 2900;
  const int xend = 5500;
  
  int yofs = 50;
  const int yofline = 250;
  /*drawCapsule("Rewrite \"/qh find\" - Find any item or NPC", xstart, yofs, xend, yofs + yofline - 50, (42.59 + 370) / 3000, dimx, dimy, "QHbar_QH_Find.png"); // $3000
  drawCapsule("Achievements (starting with exploration achievements)", xstart, yofs, xend, yofs + yofline - 50, (39.63 + 500) / 5000, dimx, dimy, "QHbar_Achievements.png"); // $6000
  drawCapsule("User-friendly configuration page", xstart, yofs, xend, yofs + yofline - 50, (4.55 + 30) / 4000, dimx, dimy, "QHbar_Configuration.png"); // $4000
  drawCapsule("Customizable quest tracker", xstart, yofs, xend, yofs + yofline - 50, (36.53 + 120) / 3000, dimx, dimy, "QHbar_Tracker.png"); // $2000*/
  
  drawCapsule("Rewrite \"/qh find\" - Find any item or NPC", xstart, yofs, xend, yofs + yofline - 50, (137.04 + 330) / 3000, dimx, dimy, "QHbar_QH_Find.png"); // $3000
  drawCapsule("Achievements (starting with exploration achievements)", xstart, yofs, xend, yofs + yofline - 50, (57.73 + 490) / 5000, dimx, dimy, "QHbar_Achievements.png"); // $6000
  drawCapsule("User-friendly configuration page", xstart, yofs, xend, yofs + yofline - 50, (42.69 + 15) / 4000, dimx, dimy, "QHbar_Configuration.png"); // $4000
  drawCapsule("Customizable quest tracker", xstart, yofs, xend, yofs + yofline - 50, (38.5 + 119) / 3000, dimx, dimy, "QHbar_Tracker.png"); // $2000
}


// https://www.paypal.com/cgi-bin/webscr?hosted_button_id=1575549&item_name=QuestHelper+%28from+Curse.com%29&cmd=_s-xclick
