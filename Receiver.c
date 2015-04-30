1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162
163
164
165
166
167
168
169
170
171
172
173
174
175
176
177
178
179
180
181
182
183
184
185
186
187
188
189
190
191
192
193
194
195
196
197
198
199
200
201
202
203
204
205
206
207
208
209
210
211
212
213
214
215
216
217
218
219
220
221
222
223
224
225
226
227
228
229
230
231
232
233
234
235
236
237
238
239
240
241
242
243
244
245
246
247
248
249
250
251
252
253
254
255
256
257
258
259
260
261
262
263
264
265
266
267
268
269
270
271
272
273
274
275
276
277
278
279
280
281
282
283
284
285
286
287
288
289
290
291
292
293
294
295
296
297
298
299
300
301
302
303
304
305
306
307
308
309
310
311
312
313
314
315
316
317
318
319
320
321
322
323
324
325
326
327
328
329
330
331
332
333
334
335
336
337
338
339
340
341
342
343
344
345
346
347
348
349
350
351
352
353
354
355
356
357
358
359
360
361
362
363
364
365
366
367
368
369
370
371
372
373
374
375
376
377
// C8051F381_ADC_multiple_inputs.c:  Shows how to use the 10-bit ADC and the
// multiplexer.  This program measures the voltages applied to pins P2.0 to P2.3.
//
// (c) 2008-2014, Jesus Calvino-Fraga
//
// ~C51~ 
 
#include <stdio.h>
#include <stdlib.h>
#include <c8051f38x.h>
#include <math.h>
 
#define MHZ 1000000L
#define SYSCLK (48*MHZ)
#define BAUDRATE 115200L
#define iterations 40000
volatile int dist = 3;
volatile float buffer = 0.4;
volatile float distance;
char _c51_external_startup (void)
{
    PCA0MD&=(~0x40) ;    // DISABLE WDT: clear Watchdog Enable bit
    // CLKSEL&=0b_1111_1000; // Not needed because CLKSEL==0 after reset
    #if (SYSCLK == (12*MHZ))
        //CLKSEL|=0b_0000_0000;  // SYSCLK derived from the Internal High-Frequency Oscillator / 4 
    #elif (SYSCLK == (24*MHZ))
        CLKSEL|=0b_0000_0010; // SYSCLK derived from the Internal High-Frequency Oscillator / 2.
    #elif (SYSCLK == (48*MHZ))
        CLKSEL|=0b_0000_0011; // SYSCLK derived from the Internal High-Frequency Oscillator / 1.
    #else
        #error SYSCLK must be either 12MHZ, 24MHZ, or 48MHZ
    #endif
    OSCICN |= 0x03; // Configure internal oscillator for its maximum frequency
     
    // Configure P2.0 to P2.3 as analog inputs
    P1MDIN &= 0b_0000_0000; // P2.0 to P2.3
    P1SKIP |= 0b_1111_1111; // Skip Crossbar decoding for these pins
 
    // Init ADC multiplexer to read the voltage between P2.0 and ground.
    // These values will be changed when measuring to get the voltages from
    // other pins.
    // IMPORTANT: check section 6.5 in datasheet.  The constants for
    // each pin are available in "c8051f38x.h" both for the 32 and 48
    // pin packages.
    AMX0P = LQFP32_MUX_P1_0; // Select positive input from P2.0
    AMX0N = LQFP32_MUX_GND;  // GND is negative input (Single-ended Mode)
     
    // Init ADC
    ADC0CF = 0xF8; // SAR clock = 31, Right-justified result
    ADC0CN = 0b_1000_0000; // AD0EN=1, AD0TM=0
    REF0CN=0b_0000_1000; //Select VDD as the voltage reference for the converter
     
    VDM0CN=0x80;       // enable VDD monitor
    RSTSRC=0x02|0x04;  // Enable reset on missing clock detector and VDD
    P0MDOUT|=0x10;     // Enable Uart TX as push-pull output
    XBR0=0x01;         // Enable UART on P0.4(TX) and P0.5(RX)
    XBR1=0x40;         // Enable crossbar and weak pull-ups
     
    #if (SYSCLK/BAUDRATE/2L/256L < 1)
        TH1 = 0x10000-((SYSCLK/BAUDRATE)/2L);
        CKCON &= ~0x0B;                  // T1M = 1; SCA1:0 = xx
        CKCON |=  0x08;
    #elif (SYSCLK/BAUDRATE/2L/256L < 4)
        TH1 = 0x10000-(SYSCLK/BAUDRATE/2L/4L);
        CKCON &= ~0x0B; // T1M = 0; SCA1:0 = 01                  
        CKCON |=  0x01;
    #elif (SYSCLK/BAUDRATE/2L/256L < 12)
        TH1 = 0x10000-(SYSCLK/BAUDRATE/2L/12L);
        CKCON &= ~0x0B; // T1M = 0; SCA1:0 = 00
    #else
        TH1 = 0x10000-(SYSCLK/BAUDRATE/2/48);
        CKCON &= ~0x0B; // T1M = 0; SCA1:0 = 10
        CKCON |=  0x02;
    #endif
    P2MDOUT|=0b_0000_00000; 
    TL1 = TH1;     // Init timer 1
    TMOD &= 0x0f;  // TMOD: timer 1 in 8-bit autoreload
    TMOD |= 0x20;                       
    TR1 = 1;       // Start timer1
    SCON = 0x52;
     
    return 0;
}
 
// Uses Timer3 to delay <us> micro-seconds. 
void Timer3us(unsigned char us)
{
    unsigned char i;               // usec counter
     
    // The input for Timer 3 is selected as SYSCLK by setting T3ML (bit 6) of CKCON:
    CKCON|=0b_0100_0000;
     
    TMR3RL = (-(SYSCLK)/1000000L); // Set Timer3 to overflow in 1us.
    TMR3 = TMR3RL;                 // Initialize Timer3 for first overflow
     
    TMR3CN = 0x04;                 // Sart Timer3 and clear overflow flag
    for (i = 0; i < us; i++)       // Count <us> overflows
    {
        while (!(TMR3CN & 0x80));  // Wait for overflow
        TMR3CN &= ~(0x80);         // Clear overflow indicator
    }
    TMR3CN = 0 ;                   // Stop Timer3 and clear overflow flag
}
 
void waitms (unsigned int ms)
{
    unsigned int j;
    unsigned char k;
    for(j=0; j<ms; j++)
        for (k=0; k<4; k++) Timer3us(250);
}
void wait_bit_time(){
    float n=iterations;
    while (n>0){
    n--;
    }
    return;
}
void wait_one_and_half_bit_time(){
    float n=1.5*iterations;
    while (n>0){
        n--;
    }
    return;
}
 
float Get_ADC(int channel){
    float v;
    int i;
    int j;
    float vpeak = 0;
    switch (channel){
                case 0:
                    AMX0P=LQFP32_MUX_P1_0;
                break;
                case 1:
                    AMX0P=LQFP32_MUX_P1_1;
                break;
                case 2:
                    AMX0P=LQFP32_MUX_P1_2;
                break;
                case 3:
                    AMX0P=LQFP32_MUX_P1_3;
                break;
                case 4:
                    AMX0P=LQFP32_MUX_P1_4;
                break;
                case 5:
                    AMX0P=LQFP32_MUX_P1_5;
                break;
                case 6:
                    AMX0P=LQFP32_MUX_P1_6;
                break;
                case 7:
                    AMX0P=LQFP32_MUX_P1_7;
                break;      
    }   
        vpeak =0;
        for(i = 0; i<20; i++){
            for(j = 0; j<100; j++){
                AD0BUSY = 1;
                while (AD0BUSY); // Wait for conversion to complete
                v = ((ADC0L+(ADC0H*0x100))*3.325)/1023.0; // Read 0-1023 value in ADC0 and convert to volts
                if(vpeak < v)
                    vpeak = v;
            }
        }
        vpeak += 0.1;
        return vpeak;
     
}
 
int rx_byte (float min)
{
    int j, val;
    int v;
    //skip the start bit
    val = 0;
    Get_ADC(1);
    wait_one_and_half_bit_time();
    for (j=0; j<8; j++)
    {
    v = Get_ADC(1);
    val|=(v>min)?(0x01<<j):0x00; //if voltage is greater than "min" then the returned val gets a bit at the right position
    wait_bit_time();
    }
    //wait for stop bits
    wait_one_and_half_bit_time();
    return val;
}
 
 
#define VDD      3.325 // The measured value of VDD in volts
 
 
void main (void)
{
 
    int byte = 300;
    float v0 = 0;
    float v1 = 0;
    float v2 = 0;
    float v3 = 0;
    float valign = 0;
    double vright = 0;
    double vleft = 0;
    int temp = 0;
    P2_0 = 1; //front LED
    P2_1 = 0; //back LED
     
    printf("\x1b[2J"); // Clear screen using ANSI escape sequence.
     
    // Start the ADC in order to select the first channel.
    // Since we don't know how the input multiplexer was set up,
    // this initial conversion needs to be discarded.
    AD0BUSY=1;
    while (AD0BUSY); // Wait for conversion to complete
 
    while(1)
    {   
         
        v0 = Get_ADC(1);
        v1 = Get_ADC(2);
        v2 = Get_ADC(3);
        v3 = Get_ADC(0);
        if(dist == 2){
            vright = v1;
            vleft = v3;
            distance = 2.8;
        }
        if(dist == 1){
            buffer = 0.2;
            vright = v0;
            vleft = v2;
            distance = 1.5;
        }
        if(dist == 3){
            vright = v1;
            vleft = v3;
            distance = 2.0;
            buffer = 0.3;
            }
        if(dist == 4){
            vright = v1;
            vleft = v3;
            distance = 1.2;
            buffer = 0.2;
            }
        if(dist == 5){
            vright = v1;
            vleft = v3;
            distance = 0.5;
            buffer = 0.3;
            }
        valign = abs(vleft-vright);     
        printf("Vright = %5.3f ", vright);
        printf("Vleft = %5.3f", vleft);
        printf("distance = %d\r", dist);
    /*  if(vleft<0.15){
            P2_2 = 0;
            P2_3 = 0;
            P2_4 = 0;
            P2_5 = 0;
            byte = rx_byte(0.2);
            printf("\n byte = %d\n", byte);
        }*/
        if(valign < 0.2){
            //straight
            if(vright+buffer>distance && vright - buffer < distance){//stay
            P2_2 = 0;
            P2_3 = 0;
            P2_4 = 0;
            P2_5 = 0;
            }
            else if (vright-buffer > distance){//back
            P2_2 = 1;
            P2_3 = 0;
            P2_4 = 0;
            P2_5 = 1;       
            }
            else{//forward
            P2_2 = 0;
            P2_3 = 1;
            P2_4 = 1;
            P2_5 = 0;
            }
        }   
        else{ 
            printf("\n\rTURNING\n\r");
            if(vright > vleft){
                P2_2 = 0;
                P2_3 = 0;
                P2_4 = 1;
                P2_5 = 0;
            }
            else{
                P2_2 = 0;
                P2_3 = 1;
                P2_4 = 0;
                P2_5 = 0;
            }
        }
             
        if(byte == 0 || byte == 1 || byte == 129 || byte == 128){ // move farther p0
            if(dist != 5){
            dist++;
            }
            byte = 300; 
        }
        if(byte == 254 || byte == 255 || byte == 253 ){ //move closer p1
            if(dist != 1){
            dist--;
            }
            byte = 300;
            printf("move closer \n");   
        }  
        if(byte == 14 || byte == 15 || byte == 7){ //rotate 180 p2
            byte = 300;
            P2_2 = 0;
            P2_3 = 1;
            P2_4 = 0;
            P2_5 = 0;
            waitms(2500);       
            P2_2 = 0;
            P2_3 = 0;
            P2_4 = 0;
            P2_5 = 0;
            if (dist != 5){
                dist++;
            }
            printf("rotate 180 \n");    
        }
        if(byte == 238 || byte == 239 || byte == 119){ //front leds p3
            P2_0 = !P2_0;
            byte = 300;
            printf("ledfront \n");      
        }
        if(byte == 56 || byte == 57 || byte == 25){ //back leds p4
            P2_1 = !P2_1;
            byte = 300;
            printf("ledback \n");           
        }
        if(byte == 246 || byte == 243 || byte ==251){ //buzzer p5
            byte = 300;
            printf("buzz on \n");           
        }   
        if(byte == 124 || byte == 125 || byte == 61){ //p park p6
            byte = 300;
            P2_2 = 0;
            P2_3 = 1;
            P2_4 = 0;
            P2_5 = 0;
            waitms(1000);
            P2_2 = 1;
            P2_3 = 0;
            P2_4 = 0;
            P2_5 = 1;
            waitms(1500);
            P2_2 = 0;
            P2_3 = 0;
            P2_4 = 1;
            P2_5 = 0;
            waitms(1000);
            P2_2 = 0;
            P2_3 = 1;
            P2_4 = 1;
            P2_5 = 0;
            waitms(500);
            P2_2 = 0;
            P2_3 = 0;
            P2_4 = 0;
            P2_5 = 0;
            waitms(2000);
            printf("park \n");          
        }
    }   
}
