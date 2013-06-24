classdef CList < handle
% 定义了一个（有序的）列表
% list = CList; 定义一个空的队列对象
% list = CList(c); 定义队列对象，并用c初始化q，当c为cell时，c的元素为栈的数据，
%    否则c本身为栈的第一个数据
%
% 支持操作：
%     sz = list.size() 返回队列内元素个数，也可用来判断队列是否非空。
%     b = list.empty() 清空队列
%     list.pushtofront(el) 将新元素el压入列表头
%     list.pushtorear(el) 将新元素el压入列表尾部
%     el = list.popfront()  弹出列表头部元素，用户需自己确保队列非空
%     el = list.poprear() 弹出列表尾部元素，用户需自己确保列表非空
%     el = list.front() 返回队首元素，用户需自己确保队列非空
%     el = list.back() 返回队尾元素，用户需自己确保队列非空
%     list.remove(k) 删除第k个元素，如果k为负的，则从尾部开始算 
%     list.removeall() 删除队列所有元素
%     list.add(el, k) 插入元素el到第k个位置，如果k为负的，则从结尾开始算
%     list.contains(el) 检查el是否出现在列表中，如果出现，返回第一个下标
%     list.get(k) 返回列表制定位置的元素，如果k为负的，则从末尾开始算
%     list.sublist(from, to) 返回列表中从from到to（左开右闭）之间的视图
%     list.content() 返回列表的数据，以一维cells数组的形式返回。
%     list.toarray() = list.content() content的别名
%
% See also CStack
%
% copyright: zhangzq@citics.com, 2010.
% url: http://zhiqiang.org/blog/tag/matlab

    properties (Access = private)
        buffer      % 一个cell数组，保存栈的数据
        beg         % 队列起始位置
        len         % 队列的长度
    end
    
    properties (Access = public)
        capacity    % 栈的容量，当容量不够时，容量扩充为2倍。
    end
    
    methods
        function obj = CList(c)
            if nargin >= 1 && iscell(c)
                obj.buffer = [c(:); cell(numel(c), 1)];
                obj.beg = 1;
                obj.len = numel(c);
                obj.capacity = 2*numel(c);
            elseif nargin >= 1
                obj.buffer = cell(100, 1);
                obj.buffer{1} = c;
                obj.beg = 1;
                obj.len = 1;
                obj.capacity = 100;                
            else
                obj.buffer = cell(100, 1);
                obj.capacity = 100;
                obj.beg = 1;
                obj.len = 0;
            end
        end
        
        function s = size(obj)
            s = obj.len;
        end
        
        function b = empty(obj)  % 判断列表是否为空
            b = (obj.len == 0);
        end
        
        function pushtorear(obj, el) % 压入新元素到队尾
            obj.addcapacity();
            if obj.beg + obj.len  <= obj.capacity
                obj.buffer{obj.beg+obj.len} = el;
            else
                obj.buffer{obj.beg+obj.len-obj.capacity} = el;
            end
            obj.len = obj.len + 1;
        end
        
        function pushtofront(obj, el) % 压入新元素到队尾
            obj.addcapacity();
            obj.beg = obj.beg - 1;
            if obj.beg == 0
                obj.beg = obj.capacity; 
            end
            obj.buffer{obj.beg} = el;
            obj.len = obj.len + 1;
        end
        
        function el = popfront(obj) % 弹出队首元素
            el = obj.buffer(obj.beg);
            obj.beg = obj.beg + 1;
            obj.len = obj.len - 1;
            if obj.beg > obj.capacity
                obj.beg = 1;
            end
        end
        
        function el = poprear(obj) % 弹出队尾元素
            tmp = obj.beg + obj.len;
            if tmp > obj.capacity
                tmp = tmp - obj.capacity;
            end
            el = obj.buffer(tmp);
            obj.len = obj.len - 1;
        end
        
        function el = front(obj) % 返回队首元素
            try
                el = obj.buffer{obj.beg};
            catch ME
                throw(ME.messenge);
            end
        end
        
        function el = back(obj) % 返回队尾元素
            try
                tmp = obj.beg + obj.len - 1;
                if tmp >= obj.capacity, tmp = tmp - obj.capacity; end;
                el = obj.buffer(tmp);
            catch ME
                throw(ME.messenge);
            end            
        end
        
        function el = top(obj) % 返回队尾元素
            try
                tmp = obj.beg + obj.len - 1;
                if tmp >= obj.capacity, tmp = tmp - obj.capacity; end;
                el = obj.buffer(tmp);
            catch ME
                throw(ME.messenge);
            end            
        end
        
        function removeall(obj) % 清空列表
            obj.len = 0;
            obj.beg = 1;
        end
        
        % 删除第k个元素，k可以为负的，表示从尾部开始算
        % 如果没有设定k，则为清空列表所有元素
        function remove(obj, k)
            if nargin == 1
                obj.len = 0;
                obj.beg = 1;
            else % k ~= 0
                id = obj.getindex(k);

                obj.buffer{id} = [];
                obj.len = obj.len - 1;
                obj.capacity = obj.capacity - 1;

                % 删除元素后，需要重新调整beg的位置值
                if id < obj.beg
                    obj.beg = obj.beg - 1;
                end
            end
        end
        
        % 插入新元素el到第k个元素之前，如果k为负数，则插入到倒数第-k个元素之后
        function add(obj, el, k)
            obj.addcapacity();
            id = obj.getindex(k);
            
            if k > 0 % 插入在第id个元素之前
                obj.buffer = [obj.buffer(1:id-1); el; obj.buffer(id:end)];
                if id < obj.beg
                    obj.beg = obj.beg + 1;
                end
            else % k < 0，插入在第id个元素之后
                obj.buffer = [obj.buffer(1:id); el; obj.buffer(id:end)];
                if id < obj.beg
                    obj.beg = obj.beg + 1;
                end
            end
        end
        
        % 依次显示队列元素
        function display(obj)
            if obj.size()
                rear = obj.beg + obj.len - 1;
                if rear <= obj.capacity
                    for i = obj.beg : rear
                        disp([num2str(i - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end
                else
                    for i = obj.beg : obj.capacity
                        disp([num2str(i - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end     
                    for i = 1 : rear
                        disp([num2str(i + obj.capacity - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end
                end
            else
                disp('The queue is empty');
            end
        end
        
        
        % 获取列表的数据内容
        function c = content(obj)
            rear = obj.beg + obj.len - 1;
            if rear <= obj.capacity
                c = obj.buffer(obj.beg:rear);                    
            else
                c = obj.buffer([obj.beg:obj.capacity 1:rear]);
            end
        end
        
        % 获取列表的数据内容，等同于obj.content();
        function c = toarray(obj)
            c = obj.content();
        end
    end
    
    
    
    methods (Access = private)
        
        % getindex(k) 返回第k个元素在buffer的下标位置
        function id = getindex(obj, k)
            if k > 0
                id = obj.beg + k;
            else
                id = obj.beg + obj.len + k;
            end     
            
            if id > obj.capacity
                id = id - obj.capacity;
            end
        end
        
        % 当buffer的元素个数接近容量上限时，将其容量扩充一倍。
        % 此时旋转列表，使得从1开始。整个列表至少有两个以上空位。
        function addcapacity(obj)
            if obj.len >= obj.capacity - 1
                sz = obj.len;
                if obj.beg + sz - 1 <= obj.capacity
                    obj.buffer(1:sz) = obj.buffer(obj.beg:obj.beg+sz-1);                    
                else
                    obj.buffer(1:sz) = obj.buffer([obj.beg:obj.capacity, ...
                        1:sz-(obj.capacity-obj.beg+1)]);
                end
                obj.buffer(sz+1:obj.capacity*2) = cell(obj.capacity*2-sz, 1);
                obj.capacity = 2*obj.capacity;
                obj.beg = 1;
            end
        end
    end % private methos
    
    methods (Abstract)
        
    end
end