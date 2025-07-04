USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spUTabuladorSalarial](
    @Nivel int,
    @TotalNiveles int=0,
    @Amplitud	decimal(18,4),
	@Progresion	decimal(18,4),
    @RedondearDecenas bit = 1,
    @Nombre varchar(150),
    @Minimo		decimal(18,2) = 0.00,
    @Maximo		decimal(18,2) = 0.00,
    @BanderaPorcentaje bit =1,
    @IDUsuario int 	
) as 

     declare @tableNiveles as table (
	 	Nivel		int,
	 	Minimo		decimal(18,2),
	 	Q1			as cast((Minimo+Medio)/2.00 as decimal(18,2)),
		Medio		decimal(18,2),
		Q3			as cast((Medio+Maximo)/2.00 as decimal(18,2)),
		Maximo		decimal(18,2),
		Amplitud	decimal(18,4),
		Progresion	decimal(18,4),
        Nombre varchar(150)
	);

    declare @tableNivelesFinal as table (
	 	Nivel		int,
	 	Minimo		decimal(18,2),
	 	Q1			as cast((Minimo+Medio)/2.00 as decimal(18,2)),
		Medio		decimal(18,2),
		Q3			as cast((Medio+Maximo)/2.00 as decimal(18,2)),
		Maximo		decimal(18,2),
		Amplitud	decimal(18,4),
		Progresion	decimal(18,4),
        Nombre varchar(150)
	);

    declare @NInicialTemp int 
    declare @NFinalTemp int 

    declare @MinNivel int 
    declare @MaxNivel int 

    declare @MinimoNext DECIMAL(18,2)
    declare @MinimoCurrent DECIMAL(18,2)
    declare @MinimoPrevious DECIMAL(18,2)
    DECLARE @MinimoTemp AS DECIMAL(18,2)    
    declare @OrderDesc bit 
     
    SELECT @MaxNivel=MAX(Nivel) ,
            @MinNivel=min(Nivel) 
    FROM rh.tblTabuladorSalarial where Nombre=@Nombre
              
    select @OrderDesc = case when  (select Minimo from RH.tblTabuladorSalarial where Nivel=@MinNivel and Nombre=@Nombre)  > 
                                (select Minimo from RH.tblTabuladorSalarial where Nivel=@MaxNivel and Nombre=@Nombre)                               
                            then 1 else 0 end     
    
    DECLARE @Nivel1 int,
        @Minimo1 decimal(18,2),
        @Medio1 decimal(18,2),
        @Maximo1 decimal(18,2),
        @Amplitud1 decimal(18,4),
        @Progresion1 decimal(18,4),
        @Nombre1 varchar(150);

    DECLARE db_cursor CURSOR FOR  
    SELECT Nivel, Minimo, Medio, Maximo, Amplitud, Progresion, Nombre
    FROM rh.tblTabuladorSalarial 
    WHERE Nombre = @Nombre 
    ORDER BY 
        case when @OrderDesc = 0		then Nivel end,			
		case when @OrderDesc = 1	then Nivel end desc 

    OPEN db_cursor;   
    FETCH NEXT FROM db_cursor INTO @Nivel1, @Minimo1, @Medio1, @Maximo1, @Amplitud1, @Progresion1, @Nombre1;

    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        INSERT INTO @tableNiveles (Nivel, Minimo, Medio, Maximo, Amplitud, Progresion, Nombre)
        VALUES (@Nivel1, @Minimo1, @Medio1, @Maximo, @Amplitud1, @Progresion1, @Nombre1);

        FETCH NEXT FROM db_cursor INTO @Nivel1, @Minimo1, @Medio1, @Maximo1, @Amplitud1, @Progresion1, @Nombre1;  
    END   

    CLOSE db_cursor;  
    DEALLOCATE db_cursor;

    
    -- insert into @tableNiveles ([Nivel], [Minimo],  [Medio],  [Maximo], [Amplitud], [Progresion], [Nombre] )
    -- select  [Nivel], [Minimo],  [Medio],  [Maximo], [Amplitud], Progresion, [Nombre] 
    -- From rh.tblTabuladorSalarial where Nombre=@Nombre order by Nivel   desc
            
    --         select  [Nivel], [Minimo],  [Medio],  [Maximo], [Amplitud], Progresion, [Nombre] 
    -- From rh.tblTabuladorSalarial where Nombre=@Nombre  

    -- select * from @tableNiveles
    -- return 
    set @NInicialTemp=@Nivel
    set @NFinalTemp = case when @OrderDesc=0 then @MaxNivel else @MinNivel end
    
    -- select @MinimoNext=Minimo from rh.tblTabuladorSalarial  where Nivel=@Nivel+1 and Nombre=@Nombre
    -- select @MinimoCurrent=Minimo from rh.tblTabuladorSalarial  where Nivel=@Nivel and Nombre=@Nombre
    -- select @MinimoPrevious=Minimo from rh.tblTabuladorSalarial  where Nivel=@Nivel-1 and Nombre=@Nombre
    
    -- IF( @MinimoCurrent > isnull(@MinimoNext,0) and  @MinimoNext IS  NULL  and @MinimoCurrent >  isnull(@MinimoPrevious,0)   )
    -- BEGIN                
    --      select  @NFinalTemp= @Nivel
    -- END 
    -- ELSE if( @MinimoCurrent < isnull(@MinimoNext,0) and  @MinimoNext IS NOT   NULL and @MinimoCurrent >  isnull(@MinimoPrevious,0)   )
    -- BEGIN                
    --      select  @NFinalTemp= MAX(Nivel) from  rh.tblTabuladorSalarial 
    -- END else 
    -- if( @MinimoCurrent > isnull(@MinimoPrevious,0) and  @MinimoPrevious IS  NULL   )
    -- BEGIN        
    --      select  @NFinalTemp= @Nivel
    -- END  ELSE if( @MinimoCurrent < isnull(@MinimoPrevious,0) and  @MinimoPrevious IS NOT   NULL )
    -- BEGIN        
    --      select  @NFinalTemp= min(Nivel) from  rh.tblTabuladorSalarial 
    -- END 
     
    UPDATE @tableNiveles  
        SET Amplitud=@Amplitud 
    WHERE Nivel=@Nivel AND Nombre=@Nombre
    
    IF @TotalNiveles > 0  
    begin                  
        ;with CTEAscTabuladorSalarial as (
             SELECT 
                    @MaxNivel +1 AS Nivel,		    
                    0 as Minimo, -- NO IMPORTA EL MINIMO
			        @Amplitud as Amplitud,
                    @Progresion as Progresion,
                    @Nombre AS Nombre     
                UNION ALL  
            SELECT  Nivel+1  as Nivel,
                    0 as Minimo, -- NO IMPORTA EL MINIMO
			        @Amplitud as Amplitud,
                    @Progresion as Progresion,
                    @Nombre AS Nombre     
                FROM  CTEAscTabuladorSalarial  
            WHERE Nivel <  (@MaxNivel +@TotalNiveles)		                                
	    )     
        insert into @tableNiveles([Nivel], [Minimo], [Amplitud], [Progresion], [Nombre])    
        select * from CTEAscTabuladorSalarial
                
        if @OrderDesc=1
        begin 
            set @NInicialTemp = @MaxNivel+@TotalNiveles
        end

        if @OrderDesc=0
        begin 
            set @NFinalTemp = @MaxNivel+@TotalNiveles
        end

    end 
   

    SET @MinimoTemp= case when @OrderDesc =0 THEN                 
                            case when @MinNivel =@NInicialTemp then 
                                @Minimo else  
                                (SELECT Minimo from @tableNiveles where Nivel=@NInicialTemp-1 )                             
                            end
                        else                              
                            case 
                                when @TotalNiveles >0 then   (SELECT Minimo from @tableNiveles where Nivel=@MaxNivel)
                                when @MaxNivel =@NInicialTemp then 
                                    @Minimo else  
                                (SELECT Minimo from @tableNiveles where Nivel=@NInicialTemp+1)                                 
                        end
                    end    
    
    -- select 
    -- @NInicialTemp AS NInicialTemp
    -- ,@Nivel AS Nivel
    -- , @MaxNivel AS MaxNivel
    -- , @MinNivel AS MinNivel
    -- ,@MinimoTemp AS MinimoTemp
    -- ,@OrderDesc AS OrderDesc
        

    IF(@BanderaPorcentaje=0)
    BEGIN
        UPDATE @tableNiveles SET 
            Minimo=   @Minimo ,
            Maximo=   @Maximo  ,
            Progresion=  cast(((@Minimo*100)/@MinimoTemp)/100 as decimal(18,4)) ,
            Amplitud= cast(((@Maximo*100)/@Minimo)/100 as decimal(18,4)) -1
        where Nivel=@NInicialTemp                
    END ELSE 
    BEGIN 
        

       if(  (@Nivel = @MaxNivel AND @OrderDesc=1 ) or (@Nivel = @MinNivel AND @OrderDesc=0) OR @TotalNiveles>0)
        BEGIN
            SET @MinimoTemp= @MinimoTemp*(@Progresion) 
        END 
        ELSE BEGIN
            SET @MinimoTemp= @MinimoTemp*(@Progresion+1) 
        END

        -- SET @MinimoTemp= @MinimoTemp*(@Progresion+1) 

        UPDATE @tableNiveles SET 
            Minimo=  @MinimoTemp ,
            Progresion=cast(@Progresion as decimal(18,4))
        where Nivel=@NInicialTemp
    END    
             
    -- select @OrderDesc as OrderDesc ,@MinimoCurrent as MinimoCurrent ,@MinimoPrevious as MinimoPrevious ,@MinimoNext as MinimoNext  ,
    --     @MaxNivel as MaxNivel,@MinNivel as MinNivel,@NInicialTemp as NInicialTemp,@MinimoTemp as MinimoTemp,
    -- @NFinalTemp as NFinalTemp
    -- select * From @tableNiveles
    
    ;with CTETabuladorSalarial as (
		select 	
                Nivel,		    
                Minimo  ,
			    cast(((Minimo +(Minimo*(Amplitud+1)))/2) as decimal(18,2) ) as Medio,
			    cast((Minimo*(Amplitud+1)) as decimal(18,2) ) as Maximo,	
			    cast(Amplitud as decimal(18,4) ) as Amplitud, 			    
                cast(Progresion as decimal(18,4) ) as Progresion, 		
                @Nombre AS Nombre
            from @tableNiveles
            where Nivel=@NInicialTemp             
                union all
            select 
                tableNiveles.Nivel,                
                cast(cte.Minimo*(tableNiveles.Progresion+1) as decimal(18,2)) as Minimo  ,	            
                cast((cte.Minimo*(tableNiveles.Progresion+1) + ((cte.Minimo*(tableNiveles.Progresion+1))/2))  as decimal(18,2)) as Medio,                
                cast(((cte.Minimo*(tableNiveles.Progresion+1))*(tableNiveles.Amplitud+1))   as decimal(18,2))  as Maximo,	            
                cast(tableNiveles.Amplitud as decimal(18,4) ) as Amplitud, 			    
                cast(tableNiveles.Progresion as decimal(18,4) ) as Progresion, 		
                
                @Nombre AS Nombre
            from @tableNiveles tableNiveles
                join CTETabuladorSalarial cte on cte.Nivel=(case when @OrderDesc =0  then tableNiveles.Nivel-1 else tableNiveles.Nivel+1 END )                
                
            where 
             tableNiveles.Nivel <> @NInicialTemp and 
                 ( 
                     (@OrderDesc =1 and (tableNiveles.Nivel)>= @NFinalTemp) or 
                    (@OrderDesc =0 and tableNiveles.Nivel <= @NFinalTemp)  
                )                             
	)     	
    insert @tableNivelesFinal(Nivel, Minimo, Medio, Maximo, Amplitud, Progresion,Nombre)
	select Nivel, Minimo, Medio, Maximo, Amplitud, Progresion,Nombre from CTETabuladorSalarial;        
     
    update @tableNivelesFinal set Progresion = Progresion  -1
    where Nivel=@Nivel and @BanderaPorcentaje=0

        -- select  * from @tableNivelesFinal;        
    
    MERGE RH.tblTabuladorSalarial AS TARGET
    USING @tableNivelesFinal as SOURCE
    on TARGET.Nivel= SOURCE.Nivel and TARGET.Nombre=@Nombre
    WHEN MATCHED THEN
        update         
            set TARGET.Minimo = case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Minimo)	else SOURCE.Minimo end,
                TARGET.Q1 = case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Q1)		else SOURCE.Q1		end,
                TARGET.Medio = case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Medio)	else SOURCE.Medio	end,
                TARGET.Q3 = case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Q3)		else SOURCE.Q3		end,
                TARGET.Maximo = case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Maximo)	else SOURCE.Maximo end,
                TARGET.Amplitud = SOURCE.Amplitud,
                TARGET.Progresion = SOURCE.Progresion
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT(Nivel,Minimo,Q1,Medio,Q3,Maximo,Amplitud,Progresion,Nombre,Estatus)
        values(SOURCE.Nivel,
    		        case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Minimo)	else SOURCE.Minimo end,
			        case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Q1)		else SOURCE.Q1		end,
			        case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Medio)	else SOURCE.Medio	end,
			        case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Q3)		else SOURCE.Q3		end,	
			        case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(SOURCE.Maximo)	else SOURCE.Maximo end,
                SOURCE.Amplitud,
                SOURCE.Progresion,
                upper(@Nombre),1);
GO
