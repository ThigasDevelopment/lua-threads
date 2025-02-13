# 🚩 Lua System Threads.

## Description
A simple threads system adapted to the lua language.

## Installation
### Requirements
- Lua
### Download and Installation Instructions
1. Clone or download the repository.
2. Place this .lua in the project you want to use.

## Example
### In this example we will see delay in the execution of processes.
```lua
local thread = Threads.new (
    function ()
        local max = 5;

        local count, delay = 0, 150;
        while (count < max) do
            print ('Thread old value: ' .. count);
            Threads.yield (delay);

            count = (count + 1);
            print ('Thread new value: ' .. count);
        end

        print ('Thread finished');
    end, 0
);
```

## Contribution
To contribute, follow the contributing guidelines and submit a pull request.

## License
This project is licensed under the MIT License.

## Credits
- Lead Developer: Thigas Development (draconzx).
