function xx = NMI_binData (x, numVx, ncellx)

minx=min(x);
maxx=max(x);
deltax=(maxx-minx)/(numVx);

lowerx=minx-deltax/2;
upperx=maxx+deltax/2;

xx=round( (x-lowerx)/(upperx-lowerx)*ncellx + 1/2 );

