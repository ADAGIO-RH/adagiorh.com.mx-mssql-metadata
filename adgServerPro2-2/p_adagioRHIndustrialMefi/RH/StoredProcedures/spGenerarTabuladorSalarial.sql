USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spGenerarTabuladorSalarial](
	@TotalNiveles int,
	@Amplitud decimal(18,2),
	@Progresion decimal(18,2),
	@SueldoInicial decimal(18,2),
	@RedondearDecenas bit = 1,
	@IDUsuario int,
    @NivelInicial int ,
    @OrderDesc bit = 1 ,
    @Nombre varchar(150)
) as

	-- delete RH.tblTabuladorSalarial 

	declare @tableNiveles as table (
		Nivel int,
		Minimo		decimal(18,2),
		Q1			as cast((Minimo+Medio)/2.00 as decimal(18,2)),
		Medio		decimal(18,2),
		Q3			as cast((Medio+Maximo)/2.00 as decimal(18,2)),
		Maximo		decimal(18,2),
		Amplitud	decimal(18,2),
		Progresion	decimal(18,2)
	);
    declare @NFinal int 
    declare @NInicial int 

    declare @NInicialTemp int 
    declare @NFinalTemp int 
    declare @MinInicialTemp decimal(18,2) 
    declare @MinFinalTemp decimal(18,2) 
            
    set @NFinal=  case  when @OrderDesc = 0 then   (@NivelInicial +@TotalNiveles)-1 else  @NivelInicial end;
    set @NInicial=  case  when @OrderDesc = 0 then   @NivelInicial else  (@NivelInicial +@TotalNiveles)-1  end;
    
    -- SELECT @NInicial AS INICIAL,@NFinal AS FINAL

    select 
        @NInicialTemp = max(Nivel),
        @NFinalTemp =min(Nivel) 
        from rh.tblTabuladorSalarial 
    where Nombre = @Nombre
    

    select @MinInicialTemp=Minimo from rh.tblTabuladorSalarial  where Nivel = @NInicialTemp and  Nombre = @Nombre
    select @MinFinalTemp=Minimo from rh.tblTabuladorSalarial  where Nivel = @NFinalTemp and  Nombre = @Nombre

    -- if(( @NInicial between @NInicialTemp and @NFinalTemp) or () )
    -- begin
    --     select 1
    -- end 
    -- select @NInicialTemp,@NFinalTemp,@MinInicialTemp,@MinFinalTemp


    ;with CTETabuladorSalarial as (
		select 
			@NInicial as Nivel,
			@SueldoInicial as Minimo,
			(@SueldoInicial+(@SueldoInicial*@Amplitud+@SueldoInicial)) / 2.00 as Medio,
			(@SueldoInicial*@Amplitud+@SueldoInicial) as Maximo,
			@Amplitud as Amplitud, 
			@Progresion as Progresion
		UNION ALL
		select 
			  case  when @OrderDesc = 0 then   Nivel + 1  else  Nivel - 1  end as  Nivel,
			 cast(Minimo + (Minimo * Progresion) as decimal(18,2)) as Minimo,	
			(cast(Minimo + (Minimo * Progresion) as decimal(18,2)) + (cast(Minimo + (Minimo * Progresion) as decimal(18,2))*(Amplitud+1))) / 2.00 as Medio,	
			(cast(Minimo + (Minimo * Progresion) as decimal(18,2))*(Amplitud+1)) as Maximo,	
			Amplitud,
			Progresion
		from CTETabuladorSalarial
		where (Nivel < @NFinal AND @OrderDesc=0 ) OR (@NFinal < Nivel AND @OrderDesc=1 )        
	)     
	insert @tableNiveles(Nivel, Minimo, Medio, Maximo, Amplitud, Progresion)
	select * from CTETabuladorSalarial

    
    MERGE RH.tblTabuladorSalarial AS TARGET
    USING @tableNiveles as SOURCE
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
                UPPER( @Nombre),1);
GO
