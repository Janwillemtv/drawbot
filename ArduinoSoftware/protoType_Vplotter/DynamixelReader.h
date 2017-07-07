#ifndef __DYNAMIXEL_READER_H__
#define __DYNAMIXEL_READER_H__

#define DYNAMIXEL_BUFFER_SIZE (128) /* Just a lot so that it will not overflow */
#define BOARD_ID 10

#define toggle(pin) digitalWrite(pin, !digitalRead(pin)) 
#define	outb(addr, data)	addr = (data)
#define	inb(addr)		(addr)
#define BV(bit)			(1<<(bit))
#define cbi(reg,bit)	reg &= ~(BV(bit))
#define sbi(reg,bit)	reg |= (BV(bit))

// Prototype for the function we need to call from outside
void DynamixelPoll(void);
void nudgeTimeOut(void);
int getTimeOut(void);

#endif

