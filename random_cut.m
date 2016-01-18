function out = random_cut( in )
    rr = randperm(5);
    style = rr(1);
    if(style == 1)
        out = in(1:224,1:224,:,:);
    end
    if(style == 2)
        out = in(17:240,1:224,:,:);
    end
    if(style == 3)
        out = in(1:224,97:320,:,:);
    end
    if(style == 4)
        out = in(17:240,97:320,:,:);
    end
    if(style == 5)
        out = in(9:232,49:272,:,:);
    end
end