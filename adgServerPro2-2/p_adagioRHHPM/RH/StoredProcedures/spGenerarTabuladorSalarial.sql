USE [p_adagioRHHPM]
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
	@IDUsuario int
) as

	delete RH.tblTabuladorSalarial 

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

		;with CTETabuladorSalarial as (
		select 
			1 as Nivel,
			@SueldoInicial as Minimo,
			(@SueldoInicial+(@SueldoInicial*@Amplitud+@SueldoInicial)) / 2.00 as Medio,
			(@SueldoInicial*@Amplitud+@SueldoInicial) as Maximo,
			@Amplitud as Amplitud, 
			@Progresion as Progresion
		UNION ALL
		select 
			Nivel + 1 as  Nivel,
			 cast(Minimo + (Minimo * Progresion) as decimal(18,2)) as Minimo,	
			(cast(Minimo + (Minimo * Progresion) as decimal(18,2)) + (cast(Minimo + (Minimo * Progresion) as decimal(18,2))*(Amplitud+1))) / 2.00 as Medio,	
			(cast(Minimo + (Minimo * Progresion) as decimal(18,2))*(Amplitud+1)) as Maximo,	
			Amplitud,
			Progresion
		from CTETabuladorSalarial
		where Nivel < @TotalNiveles
	) 

	insert @tableNiveles(Nivel, Minimo, Medio, Maximo, Amplitud, Progresion)
	select * from CTETabuladorSalarial

	insert RH.tblTabuladorSalarial(Nivel,Minimo,Q1,Medio,Q3,Maximo,Amplitud,Progresion)
	select 
			Nivel,
			case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(Minimo)	else Minimo end,
			case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(Q1)		else Q1		end,
			case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(Medio)	else Medio	end,
			case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(Q3)		else Q3		end,	
			case when isnull(@RedondearDecenas, 0) = 1 then App.fnRedondearDecenas(Maximo)	else Maximo end,
			Amplitud,
			Progresion
	from @tableNiveles
GO
