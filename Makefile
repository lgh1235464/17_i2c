CROSS_COMPILE 	?= arm-linux-gnueabihf-
TARGET		  	?= ap3216c

CC 				:= $(CROSS_COMPILE)gcc
LD				:= $(CROSS_COMPILE)ld
OBJCOPY 		:= $(CROSS_COMPILE)objcopy
OBJDUMP 		:= $(CROSS_COMPILE)objdump

LIBPATH			:= -lgcc -L /usr/local/arm/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/lib/gcc/arm-linux-gnueabihf/4.9.4


INCDIRS 		:= imx6ul \
				   stdio/include \
				   bsp/clk \
				   bsp/led \
				   bsp/delay  \
				   bsp/beep \
				   bsp/gpio \
				   bsp/key \
				   bsp/exit \
				   bsp/int \
				   bsp/epittimer \
				   bsp/keyfilter \
				   bsp/uart \
				   bsp/lcd \
				   bsp/rtc \
				   bsp/i2c \
				   bsp/ap3216c
				   			   
SRCDIRS			:= project \
				   stdio/lib \
				   bsp/clk \
				   bsp/led \
				   bsp/delay \
				   bsp/beep \
				   bsp/gpio \
				   bsp/key \
				   bsp/exit \
				   bsp/int \
				   bsp/epittimer \
				   bsp/keyfilter \
				   bsp/uart \
				   bsp/lcd \
				   bsp/rtc \
				   bsp/i2c \
				   bsp/ap3216c
				   
				   
INCLUDE			:= $(patsubst %, -I %, $(INCDIRS))

SFILES			:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.S))
CFILES			:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.c))

SFILENDIR		:= $(notdir  $(SFILES))
CFILENDIR		:= $(notdir  $(CFILES))

SOBJS			:= $(patsubst %, obj/%, $(SFILENDIR:.S=.o))
COBJS			:= $(patsubst %, obj/%, $(CFILENDIR:.c=.o))
OBJS			:= $(SOBJS) $(COBJS)

VPATH			:= $(SRCDIRS)

.PHONY: clean

# 新增：定义下载工具
IMXDOWNLOAD 	:= ./imxdownload
UUU				:= sudo uuu

#将run添加到伪目标
.PHONY: clean run

# 修改：让默认目标生成 .imx 文件
all: $(TARGET).imx

$(TARGET).imx : $(TARGET).bin
	$(IMXDOWNLOAD) $(TARGET).bin $(TARGET).imx

# 新增：USB下载执行目标
run: $(TARGET).imx
	@echo "---------- Start USB Download ----------"
	$(UUU) $(TARGET).imx


$(TARGET).bin : $(OBJS)
	$(LD) -Timx6ul.lds -o $(TARGET).elf $^ $(LIBPATH)
	$(OBJCOPY) -O binary -S $(TARGET).elf $@
	$(OBJDUMP) -D -m arm $(TARGET).elf > $(TARGET).dis

$(SOBJS) : obj/%.o : %.S
	$(CC) -Wall -nostdlib -fno-builtin -c -O2  $(INCLUDE) -o $@ $<

$(COBJS) : obj/%.o : %.c
	$(CC) -Wall -Wa,-mimplicit-it=thumb -nostdlib -fno-builtin -c -O2  $(INCLUDE) -o $@ $<
	
clean:
	rm -rf $(TARGET).elf $(TARGET).dis $(TARGET).bin $(TARGET).imx $(COBJS) $(SOBJS)


	
