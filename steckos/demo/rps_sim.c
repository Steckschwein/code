// MIT License
//
// Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// idea and concept from https://github.com/orosmatthew/rock-paper-scissors/blob/master/src/rock_paper_scissors.cpp

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <conio.h>

#include <vdp.h>
#include <steckschwein.h>


#define PIECES_COUNT 60

#define SCREEN_WIDTH 255
#define SCREEN_HEIGHT 211

#define BLACK 0

#define maxiterations 50

#define fpshift (12)

#define tofp(_x)        ((_x)<<fpshift)
#define fromfp(_x)      ((_x)>>fpshift)
#define fpabs(_x)       (abs(_x))

#define mulfp(_a,_b)    ((((signed long)_a)*(_b))>>fpshift)
#define divfp(_a,_b)    ((((signed long)_a)<<fpshift)/(_b))

#define grb(_code) ((_code>>8 & 0xe0) | (_code>>19 & 0x1c) | (_code>>6 & 0x3))

/**
 * @brief Types of pieces
 */
typedef enum {
    e_rock,
    e_paper,
    e_scissors,
} PieceType;

typedef struct {
  unsigned char x;
  unsigned char y;
} Vector2;

/**
 * @brief Piece state
 */
typedef struct {
    PieceType type;
    Vector2 *prev_pos;
    Vector2 *pos;
} Piece;

static Piece pieces[PIECES_COUNT];

static char colors[3] = {
  grb(0x676d6e),// rock
  grb(0xffffff),// paper
  grb(0xf0a0a0),// scissor
};

/**
 * @brief Initialize pieces list
 * @param count - Number of pieces
 * @param screen_width
 * @param screen_height
 * @return - Returns list of pieces
 */
static Vector2 *get_random_value(int screen_width, int screen_height){

  Vector2 *v = malloc(sizeof(Vector2));
  v->x = rand() % screen_width;
  v->y = rand() % screen_height;
  return v;
}

static void init_pieces(int screen_width, int screen_height)
{
    int i;
    Piece p;
    for (i = 0; i < PIECES_COUNT; i++) {

        Vector2 *random_pos = get_random_value(screen_width, screen_height);
        Vector2 *prev_pos = malloc(sizeof(Vector2));
        prev_pos->x = random_pos->x;
        prev_pos->y = random_pos->y;

        p.type = (PieceType)i % 3;
        p.pos = random_pos;
        p.prev_pos = prev_pos;

        pieces[i] = p;
    }
    for (i = 0; i < PIECES_COUNT; i++) {
      Piece *p;
      p = &pieces[i];
//      printf("%p %d %p %p\n", p, p->type, p->pos, p->prev_pos);
    }
}

static short DistanceSqr(Vector2 *p1, Vector2 *p2){
  int a = p1->x-p2->x;
  int b = p1->y-p2->y;
  return sqrts(a*a + b*b);
}


static short estimate_closest_diff_piece(short piece_index, int samples)
{
    signed short min_dist = 0xff;
    short min_piece_index = 0;
    short sample_count = 0;
    short i;
    short dist;
    Piece rand_piece;

    for (i = 0; i < PIECES_COUNT; i++) {
        // Get random piece
        short rand_index = rand() % PIECES_COUNT;
        rand_piece = pieces[rand_index];

        // If same type, skip
        if (rand_piece.type == pieces[piece_index].type) {
            continue;
        }
        sample_count++;
        dist = DistanceSqr(pieces[piece_index].prev_pos, rand_piece.prev_pos);
        if (dist < min_dist) {
            min_dist = dist;
            min_piece_index = rand_index;
        }
        if (sample_count >= samples) {
            break;
        }
    }
    return min_piece_index;
}

static signed char are_pieces_attracted(const Piece *p1, const Piece *p2)
{
    switch (p1->type) {
    case e_rock:
        switch (p2->type) {
        case e_rock:
            return -1;
        case e_paper:
            return 0;
        case e_scissors:
            return 1;
        }
    case e_paper:
        switch (p2->type) {
        case e_rock:
            return 1;
        case e_paper:
            return -1;
        case e_scissors:
            return 0;
        }
    case e_scissors:
        switch (p2->type) {
        case e_rock:
            return 0;
        case e_paper:
            return 1;
        case e_scissors:
            return -1;
        }
    }
    return -1;
}

short isqrt(short number)
{
  short i;
  short y;
  short x2;
  const short threehalfs = divfp(3,tofp(2));
  const short half = divfp(1,tofp(2));

  y  = tofp(number);
  x2 = mulfp(y,  half);
  i  = * ( short * ) &y;                       // evil floating point bit level hacking
  i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
  y  = * ( short * ) &i;
  y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
  // y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

  return fromfp(y);
}

static void move(Piece *p1, Piece *p2, short s){
  short l;
  short dx,dy;
  dx = p2->prev_pos->x - p1->prev_pos->x;
  dy = p2->prev_pos->y - p1->prev_pos->y;
  //l = divfp(s, sqrts(dx*dx + dy*dy));
  l = mulfp(s, isqrt(dx*dx + dy*dy));
  p1->pos->x = (p1->pos->x+mulfp(dx, l));
  p1->pos->y = (p1->pos->y+mulfp(dy, l));
  //printf("%d %d %d %d %d/%d\n", l, s, dx, dy, p1->pos->x, p1->pos->y);
}

static void update_pieces_pos(
    short screen_width,
    short screen_height,
    short close_samples)
{
    // Update previous positions before updating them
    short i;
    short min_piece_index;
    signed char is_attracted;
    short repel_speed = -1;
    short attract_speed = 2;

    Piece p1;
    Piece p2;
    for (i=0;i<PIECES_COUNT;i++) {
        pieces[i].prev_pos->x = pieces[i].pos->x;
        pieces[i].prev_pos->y = pieces[i].pos->y;
    }

    for (i = 0; i < PIECES_COUNT; i++) {
        // Get the closest different piece from a number of samples
        min_piece_index = estimate_closest_diff_piece(i, close_samples);

        // If a close piece cannot be found
        //printf("min_piece_index %d\n", min_piece_index);
        if (min_piece_index == -1) {
            continue;
        }

        p1 = pieces[i];
        p2 = pieces[min_piece_index];

        // Calculate interaction
        is_attracted = are_pieces_attracted(&p1, &p2);

        // If pieces are the same, skip
        if (is_attracted == -1) {
            continue;
        }
        //printf("is_attracted %d\n", is_attracted);
        if (is_attracted) {
            move(&p1, &p2, attract_speed);
        }
        else {
            move(&p1, &p2, repel_speed);
        }

        // Clamp positions so they cannot leave the screen
//        p1.pos.x = std::clamp(p1.pos.x, 0.0f, static_cast<float>(screen_width) - static_cast<float>(piece_size));
  //      float hud_offset = 30.0f;
    //    if (!is_hud_shown) {
      //      hud_offset = 0.0f;
        //}
//        p1.pos.y = std::clamp(p1.pos.y, hud_offset, static_cast<float>(screen_height) - static_cast<float>(piece_size));
    }
}

static void update_piece_types(Piece *p1, Piece *p2)
{
    // Quick exit if pieces are far apart
/*
    if (p1.pos.DistanceSqr(p2.pos) > (powf(static_cast<float>(piece_size), 2) * 2)) {
        return;
    }
*/

/*
    const float inner_padding = static_cast<float>(piece_size) * 0.15f;
    const raylib::Vector2 piece_size_vec(
        static_cast<float>(piece_size) - inner_padding, static_cast<float>(piece_size) - inner_padding);
    const raylib::Rectangle p1_rect(p1.pos, piece_size_vec);
    const raylib::Rectangle p2_rect(p2.pos, piece_size_vec);
    if (!p1_rect.CheckCollision(p2_rect)) {
        return;
    }
*/
    if(abs(p1->pos->x - p2->pos->x) >2 || abs(p1->pos->y - p2->pos->y) >2){
      return;
    }

    switch (p1->type) {
    case e_rock:
        switch (p2->type) {
        case e_rock:
            return;
        case e_paper:
            p1->type = e_paper;
            //play_piece_sound(res, e_paper);
            return;
        case e_scissors:
            p2->type = e_rock;
            //play_piece_sound(res, e_rock);
            return;
        }
    case e_paper:
        switch (p2->type) {
        case e_rock:
            p2->type = e_paper;
            //play_piece_sound(res, e_paper);
            return;
        case e_paper:
            return;
        case e_scissors:
            p1->type = e_scissors;
            //play_piece_sound(res, e_scissors);
            return;
        }
    case e_scissors:
        switch (p2->type) {
        case e_rock:
            p1->type = e_rock;
            //play_piece_sound(res, e_rock);
            return;
        case e_paper:
            p2->type = e_scissors;
            //play_piece_sound(res, e_scissors);
            return;
        case e_scissors:
            return;
        }
    }
}


/**
 * @brief Draw pieces
 * @param pieces - Pieces list
 * @param res - Resources for piece textures
 * @param blend - Blend fraction for position interpolation
 */
static void draw_pieces()
{
    int i;
    Piece *p;
    for (i=0;i<PIECES_COUNT;i++) {

        p = &pieces[i];
        vdp_plot(p->prev_pos->x, p->prev_pos->y, BLACK);
        vdp_plot(p->pos->x, p->pos->y, colors[p->type]);
    }
}

unsigned short cnt(PieceType pt){
  unsigned short c = 0;
  unsigned short i;
  for(i=0;i<PIECES_COUNT;i++)
    c += pieces[i].type == pt ? 1 : 0;
  return c;
}

static void main_loop()
{
    short i,j;
    Piece *p1,*p2;
    // Pause with keyboard shortcut
    /*
    if (IsKeyPressed(KEY_P)) {
        if (state.is_paused) {
            state.is_paused = false;
        }
        else {
            state.is_paused = true;
        }
    }
*/
/*
        if (state.is_paused) {
            return;
        }
*/
    update_pieces_pos(SCREEN_WIDTH, SCREEN_HEIGHT, 3);

    for(i=0;i<PIECES_COUNT-1;i++){
      p1 = &pieces[i];
      for(j=i+1;j<PIECES_COUNT;j++){
        p2 = &pieces[j];
        //printf("%p %p r: %d p: %d s: %d\n", p1, p2, cnt(e_rock),cnt(e_paper),cnt(e_scissors));
        update_piece_types(p1, p2);
      }
    }

    draw_pieces();

    // Restart
    /*
    if (state.ui_states.restart_pressed || IsKeyPressed(KEY_SPACE)) {
        state.pieces = init_pieces(state.piece_count, state.screen_width, state.screen_height);
    }
    */
}

int main ()
{
    _randomize();

    vdp_screen(7);
    vdp_blank(0);
    /*
    */

    init_pieces(SCREEN_WIDTH, SCREEN_HEIGHT);

    while (!kbhit()){
      main_loop();
    };

    return EXIT_SUCCESS;
}
