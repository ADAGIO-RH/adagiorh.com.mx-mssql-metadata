USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Compensaciones].[spGenerarMatrizIncremento]--1,1
(
	@IDMatrizIncremento int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
	@ValorInicial			decimal(18,4) ,
	@QtyNivelesAmplitud		int ,
	@ValorNivelesAmplitud	decimal(18,4) ,
	@ValorCentralAmplitud	decimal(18,4) ,
	@QtyNivelesProgresion	int ,
	@ValorNivelesProgresion decimal(18,4),
	@MiddleNivelAmplitud	int,
	@Progresiva				bit = 0 
	
	Select 
		@ValorInicial			= M.ValorInicial			
		,@QtyNivelesAmplitud		= M.QtyNivelesAmplitud		
		,@ValorNivelesAmplitud	= M.ValorNivelesAmplitud	
		,@ValorCentralAmplitud	= M.ValorCentralAmplitud	
		,@QtyNivelesProgresion	= M.QtyNivelesProgresion	
		,@ValorNivelesProgresion	= M.ValorNivelesProgresion
		,@Progresiva				= M.Progresiva
	FROM Compensaciones.tblMatrizIncremento M
	WHERE M.IDMatrizIncremento = @IDMatrizIncremento

	declare @tableMatriz as table (
		IDMatrizIncremento int ,
		ValorNivelAmplitud decimal(18,4),
		ValorNivelProgresion decimal(18,4),
		Valor Decimal(18,4)
	);
	set @MiddleNivelAmplitud = CEILING( CAST(@QtyNivelesAmplitud as decimal(18,2))/2)
	
	declare @tableMatrizAmplitud as table (
		NivelAmplitud decimal(18,4) ,
		MiddleNivelAmplitud decimal(18,4) ,
		ValorCentralAmplitud decimal(18,4),
		ValorAmplitud decimal(18,4),
		ValorNivelesAmplitud  as CASE WHEN NivelAmplitud < MiddleNivelAmplitud THEN ValorCentralAmplitud - ((MiddleNivelAmplitud -  NivelAmplitud) * ValorAmplitud)
												   WHEN NivelAmplitud = MiddleNivelAmplitud THEN ValorCentralAmplitud 
												   WHEN NivelAmplitud > MiddleNivelAmplitud THEN ValorCentralAmplitud + ((NivelAmplitud - MiddleNivelAmplitud ) * ValorAmplitud)
												   else 0
												   end
	);



	
	;with CTEMatrizAmplitud as (
		select 
			1 as NivelAmplitud,
			@MiddleNivelAmplitud as MiddleNivelAmplitud,
			@ValorCentralAmplitud as ValorCentralAmplitud,
			@ValorNivelesAmplitud as ValorAmplitud
		UNION ALL
		select 
			NivelAmplitud + 1 as  NivelAmplitud,
			@MiddleNivelAmplitud as MiddleNivelAmplitud,
			@ValorCentralAmplitud as ValorCentralAmplitud,
			@ValorNivelesAmplitud as ValorAmplitud
			
		from CTEMatrizAmplitud
		where NivelAmplitud <  @QtyNivelesAmplitud
	)
	insert @tableMatrizAmplitud(NivelAmplitud,MiddleNivelAmplitud,ValorCentralAmplitud,ValorAmplitud)
	select NivelAmplitud,MiddleNivelAmplitud, ValorCentralAmplitud, ValorAmplitud
	from CTEMatrizAmplitud

	--select * from @tableMatrizAmplitud

	declare @tableMatrizProgresion as table (
		NivelProgresion int ,
		NivelProgresionMax int ,
		ValorNivelesProgresion decimal(18,4) ,
		ValorInicial decimal(18,4), 
		Valor as  CASE WHEN CASE WHEN NivelProgresion = NivelProgresionMax THEN ValorInicial
								 WHEN NivelProgresion < NivelProgresionMax THEN ValorInicial - ((cast(NivelProgresionMax as decimal(18,4)) - cast(NivelProgresion as decimal(18,4)))*( Cast(ValorNivelesProgresion as decimal(18,4))))
									ELSE 0
								END >= 0 THEN CASE WHEN NivelProgresion = NivelProgresionMax THEN ValorInicial
											   WHEN NivelProgresion < NivelProgresionMax THEN ValorInicial - ((cast(NivelProgresionMax as decimal(18,4)) - cast(NivelProgresion as decimal(18,4)))*(cast( ValorNivelesProgresion as decimal(18,4))))
											   ELSE 0
											   END 
						ELSE 0
						END
	);

	--	select @ValorNivelesProgresion
	;with CTEMatrizProgresion as (
		select 
			1 as NivelProgresion,
			@QtyNivelesProgresion as NivelProgresionMax,
			@ValorNivelesProgresion as ValorNivelesProgresion,
			@ValorInicial as ValorInicial
		UNION ALL
		select 
			NivelProgresion + 1 as  NivelProgresion,
			@QtyNivelesProgresion as NivelProgresionMax,
			@ValorNivelesProgresion as ValorNivelesProgresion,
			@ValorInicial as ValorInicial
			
			
		from CTEMatrizProgresion
		where NivelProgresion < @QtyNivelesProgresion
	)
	insert @tableMatrizProgresion(NivelProgresion,NivelProgresionMax,ValorNivelesProgresion,ValorInicial)
	select NivelProgresion,NivelProgresionMax,ValorNivelesProgresion,ValorInicial
	from CTEMatrizProgresion

	--select * from @tableMatrizProgresion


	insert into @tableMatriz(
		IDMatrizIncremento 
		,ValorNivelAmplitud 
		,ValorNivelProgresion 
		,Valor
	)
	Select @IDMatrizIncremento,
		a.ValorNivelesAmplitud,
		ValorNivelProgresion = p.NivelProgresion,
		valorFinal = CASE WHEN a.ValorNivelesAmplitud > a.ValorCentralAmplitud THEN (a.valorCentralAmplitud - (a.ValorNivelesAmplitud - a.ValorCentralAmplitud)) * CASE WHEN ISNULL(@Progresiva,0) = 1 THEN p.Valor ELSE P.ValorInicial END
						   WHEN a.ValorNivelesAmplitud = a.ValorCentralAmplitud THEN (a.valorCentralAmplitud - (a.ValorNivelesAmplitud - a.ValorCentralAmplitud)) * CASE WHEN ISNULL(@Progresiva,0) = 1 THEN p.Valor ELSE P.ValorInicial END
						   WHEN a.ValorNivelesAmplitud < a.ValorCentralAmplitud THEN (a.valorCentralAmplitud + (a.ValorCentralAmplitud - a.ValorNivelesAmplitud )) * CASE WHEN ISNULL(@Progresiva,0) = 1 THEN p.Valor ELSE P.ValorInicial END
						   else 0
						   end 
	from @tableMatrizAmplitud a
		cross apply @tableMatrizProgresion p
	order by p.NivelProgresion desc, a.ValorNivelesAmplitud desc

	DELETE [Compensaciones].[TblMatrizIncrementoDetalle]
	WHERE IDMatrizIncremento = @IDMatrizIncremento
	
	Insert into [Compensaciones].[TblMatrizIncrementoDetalle](
	IDMatrizIncremento
	,ValorNivelAmplitud
	,ValorNivelProgresion
	,Valor)
	Select 
		IDMatrizIncremento 
		,ValorNivelAmplitud 
		,ValorNivelProgresion 
		,Valor
	FROM 
	@tableMatriz
END
GO
