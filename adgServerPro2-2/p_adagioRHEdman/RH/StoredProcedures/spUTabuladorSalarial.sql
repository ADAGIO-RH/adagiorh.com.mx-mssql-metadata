USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spUTabuladorSalarial](
	@Nivel		int,
	@Minimo		decimal(18,2),
	@Q1			decimal(18,2),
	@Medio		decimal(18,2),
	@Q3			decimal(18,2),
	@Maximo		decimal(18,2),
	@Amplitud	decimal(18,2),
	@Progresion	decimal(18,2),
	@IDUsuario int
) as 

	update RH.tblTabuladorSalarial
		set 
			Minimo	   = @Minimo	,
			Q1		   = @Q1		,
			Medio	   = @Medio		,
			Q3		   = @Q3		,
			Maximo	   = @Maximo	,
			Amplitud   = @Amplitud	,
			Progresion = @Progresion
	where Nivel = @Nivel

	declare @tableNiveles as table (
		Nivel		int,
		Minimo		decimal(18,2),
		Q1			as cast((Minimo+Medio)/2.00 as decimal(18,2)),
		Medio		decimal(18,2),
		Q3			as cast((Medio+Maximo)/2.00 as decimal(18,2)),
		Maximo		decimal(18,2),
		Amplitud	decimal(18,2),
		Progresion	decimal(18,2)
	);

	declare @tableNiveles2 as table (
		Nivel		int,
		Minimo		decimal(18,2),
		Q1			as cast((Minimo+Medio)/2.00 as decimal(18,2)),
		Medio		decimal(18,2),
		Q3			as cast((Medio+Maximo)/2.00 as decimal(18,2)),
		Maximo		decimal(18,2),
		Amplitud	decimal(18,2),
		Progresion	decimal(18,2)
	);
	


	DECLARE @json VARCHAR(MAX)
		,@Fecha date

	insert into @tableNiveles(
	Nivel
	,Minimo
	,Medio
	,Maximo
	,Amplitud
	,Progresion
	)
	SELECT 
	Nivel
	,Minimo
	,Medio
	,Maximo
	,Amplitud
	,Progresion
	FROM  
	RH.tblTabuladorSalarial

	

	update @tableNiveles
		set 
			Amplitud   = @Amplitud	,
			Progresion = @Progresion
	where Nivel = @Nivel

	--select * from @tableNiveles
	
	DECLARE @TotalNiveles int
		,@SueldoInicial decimal(18,2)
	   , @RedondearDecenas bit = 1

	Select @TotalNiveles = MAX(Nivel)
		,@RedondearDecenas = 1
	from RH.tblTabuladorSalarial U

	select @SueldoInicial = minimo
	from @tableNiveles
	where Nivel = @Nivel

	;with CTETabuladorSalarial as (
		select 
			@Nivel as Nivel,
			@SueldoInicial as Minimo,
			(@SueldoInicial+(@SueldoInicial*@Amplitud+@SueldoInicial)) / 2.00 as Medio,
			(@SueldoInicial*@Amplitud+@SueldoInicial) as Maximo,
			@Amplitud as Amplitud, 
			@Progresion as Progresion
		UNION ALL
		select 
			Nivel + 1 as  Nivel,
			cast(Minimo - (Minimo * Progresion) as decimal(18,2)) as Minimo,	
			(cast(Minimo - (Minimo * Progresion) as decimal(18,2))
				+ (cast(Minimo - (Minimo * Progresion) as decimal(18,2))*(Amplitud+1))) / 2.00 as Medio,	
			(cast(Minimo - (Minimo * Progresion) as decimal(18,2))*(Amplitud+1)) as Maximo,	
			Amplitud,
			Progresion
		from CTETabuladorSalarial
		where Nivel < @TotalNiveles 
	) 

	insert @tableNiveles2(Nivel, Minimo, Medio, Maximo, Amplitud, Progresion)
	select * from CTETabuladorSalarial
	OPTION (MAXRECURSION 0)

	--select * from @tableNiveles2

	update a
		set a.Minimo = b.Minimo,
			a.Medio = b.Medio,
			a.Maximo = b.Maximo

	from @tableNiveles A
		join @tableNiveles2 B
		on a.Nivel  = b.Nivel

	set @json = (select 
						*
				from @tableNiveles
				FOR JSON AUTO)	
	
	Delete RH.tblTabuladorSalarial

	insert into RH.tblTabuladorSalarial
	select * from @tableNiveles
GO
