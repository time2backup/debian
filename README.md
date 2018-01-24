# time2backup debian package

Build the [time2backup](https://time2backup.org) debian package.

## Build instructions
1. Clone time2backup in the current directory: `git clone https://github.com/time2backup/time2backup.git`
2. Init and update the submodules: `cd time2backup && git submodule update --init --recursive`
3. Run `./build.sh` script (you need to have sudo access)
4. Package and checksum are available in the `build/` directory

## License
This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for the full license text.

## Credits
Author: Jean Prunneaux  [http://jean.prunneaux.com](http://jean.prunneaux.com)

time2backup website: [https://time2backup.org](https://time2backup.org)
