//================================================================================
// Image Viewer (imagemagick)
//================================================================================

#ifndef _IMAGE_VIEWER_HPP_
#define _IMAGE_VIEWER_HPP_

#include <limits.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/wait.h>

class ImageViewer
{
public:
	//------------------------------------------------------------
	// constructor
	ImageViewer(void)
	: disp_pid(0), map_y(NULL), map_u(NULL), map_v(NULL)
	{
		fmt[0] = 0;
		path[0] = 0;
	}

	//------------------------------------------------------------
	// destructor
	~ImageViewer(void)
	{
		close();
	}

	//------------------------------------------------------------
	// open preview window
	bool open(const char* format, const char* name, int frames,
				int width, int height, int interval = 100)
	{
		strcpy(fmt, format);
		f = frames;
		org_w = width;
		org_h = height;
		w = (org_w + 15) & ~15;
		h = (org_h + 15) & ~15;
		win_w = w * frames;
		win_h = h * 2 + h / 2;
		size_t y_size = win_w * win_h;
		map_size = y_size + y_size / 2;

		sprintf(path, "/ImageViewer_%d_%s.bin", getpid(), name);
		int fd = shm_open(path, O_RDWR | O_CREAT, S_IRUSR);
		if(fd < 0) return false;
		ftruncate(fd, map_size);
		map_y = (char*)mmap(NULL, map_size, PROT_READ | PROT_WRITE,
							MAP_SHARED, fd, 0);
		::close(fd);
		if(!map_y) return false;
		memset(map_y, 16, y_size);
		map_u = map_y + y_size;
		map_v = map_u + y_size / 4;
		memset(map_u, 128, y_size / 2);

		int pid;
		if((pid = fork()) == 0)
		{
			char arg_size[32], arg_delay[16], arg_path[PATH_MAX];
			sprintf(arg_size, "%dx%d", win_w, win_h);
			sprintf(arg_delay, "%d", interval);
			strcpy(arg_path, fmt);
			strcat(arg_path, ":/dev/shm");
			strcat(arg_path, path);
			execlp("display", "display",
					"-size", arg_size,
					"-delay", arg_delay,
					"-colorspace", "RGB",
					"-sampling-factor", "4:2:0",
					"-depth", "8",
					arg_path, NULL);
			// never reached
			path[0] = 0;
			map_y = NULL;
			exit(-1);
		}
		else if(pid < 0)
			return false;

		disp_pid = pid;
		return true;
	}

	//------------------------------------------------------------
	// close preview window
	void close(void)
	{
		if(disp_pid)
		{
			kill(disp_pid, SIGTERM);
			waitpid(disp_pid, NULL, 0);
			disp_pid = 0;
		}

		if(path[0])
		{
			shm_unlink(path);
			path[0] = 0;
		}

		if(map_y)
		{
			munmap(map_y, map_size);
			map_y = map_u = map_v = NULL;
		}
	}

	//------------------------------------------------------------
	// is opened?
	bool is_opened(void) const
	{
		return disp_pid > 0 ? true : false;
	}

	//------------------------------------------------------------
	// check range
	bool check_range(int fr, int x, int y) const
	{
		return (!map_y || fr < 0 || fr >= f ||
			x < 0 || x >= w || y < 0 || y >= h) ? false : true;
	}

	//------------------------------------------------------------
	// write data (Y component)
	template <typename T>
	void write_y(int fr, int x, int y, T value)
	{
		if(!check_range(fr, x, y)) return;
		*((T*)(map_y + w * (f * y + fr) + x)) = value;
		*((T*)(map_y + w * (f * (h + y) + fr) + x)) = value;
	}

	//------------------------------------------------------------
	// read data (Y component)
	template <typename T>
	T read_y(int fr, int x, int y) const
	{
		if(!check_range(fr, x, y)) return 0;
		return *((T*)(map_y + w * (f * y + fr) + x));
	}

	//------------------------------------------------------------
	// write data (U/Cb component)
	template <typename T>
	void write_u(int fr, int x, int y, T value)
	{
		if(!check_range(fr, x, y)) return;
		x >>= 1;
		y >>= 1;
		*((T*)(map_u + (w / 2) * (f * y + fr) + x)) = value;
		*((T*)(map_y + w * (f * (y + h * 2) + fr) + x)) =
			read_u<T>(fr, x * 2, y * 2);
	}

	template <typename T>
	void write_cb(int fr, int x, int y, T value)
	{
		write_u<T>(fr, x, y, value);
	}

	//------------------------------------------------------------
	// read data (U/Cb component)
	template <typename T>
	T read_u(int fr, int x, int y) const
	{
		if(!check_range(fr, x, y)) return 0;
		x >>= 1;
		y >>= 1;
		return *((T*)(map_u + (w / 2) * (f * y + fr) + x));
	}

	template <typename T>
	T read_cb(int fr, int x, int y) const
	{
		return read_u<T>(fr, x, y);
	}

	//------------------------------------------------------------
	// write data (V/Cr component)
	template <typename T>
	void write_v(int fr, int x, int y, T value)
	{
		if(!check_range(fr, x, y)) return;
		x >>= 1;
		y >>= 1;
		*((T*)(map_v + (w / 2) * (f * y + fr) + x)) = value;
		*((T*)(map_y + w * (f * (y + h * 2) + fr) + x + w / 2)) =
			read_v<T>(fr, x * 2, y * 2);
	}

	template <typename T>
	void write_cr(int fr, int x, int y, T value)
	{
		write_v<T>(fr, x, y, value);
	}

	//------------------------------------------------------------
	// read data (V/Cr component)
	template <typename T>
	T read_v(int fr, int x, int y) const
	{
		if(!check_range(fr, x, y)) return 0;
		x >>= 1;
		y >>= 1;
		return *((T*)(map_v + (w / 2) * (f * y + fr) + x));
	}

	template <typename T>
	T read_cr(int fr, int x, int y) const
	{
		return read_v<T>(fr, x, y);
	}

	//------------------------------------------------------------
	// get picture size
	void get_picture_size(int* w, int* h) const
	{
		if(w) *w = this->w;
		if(h) *h = this->h;
	}

private:
	pid_t disp_pid;
	char fmt[16];
	char path[PATH_MAX];
	char *map_y, *map_u, *map_v;
	size_t map_size;
	int f, w, h, org_w, org_h, win_w, win_h;
};

#endif	/* !_IMAGE_VIEWER_HPP_ */

