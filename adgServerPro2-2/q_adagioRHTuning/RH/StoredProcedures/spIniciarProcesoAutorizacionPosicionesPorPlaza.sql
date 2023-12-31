USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc RH.spIniciarProcesoAutorizacionPosicionesPorPlaza(
	@IDPlaza int,
	@IDUsuario int
) as
	declare @IDPosicion int;

	declare @tempPosiciones as table (
		IDPosicion		   int
		,IDPlaza		   int
		,CodigoPlaza	   varchar(max)
		,Plaza			   varchar(max)
		,IDCliente		   int
		,Cliente		   varchar(max)
		,Codigo			   varchar(max)
		,ParentId		   int
		,IDEstatusPosicion int
		,IDEstatus		   int
		,Estatus		   varchar(max)
		,IDUsuario 		   int
		,FechaRegEstatus   datetime
	)

	insert @tempPosiciones
	exec [RH].[spBuscarPosiciones] @IDPlaza = @IDPlaza, @IDUsuario = @IDUsuario

	delete @tempPosiciones where IDEstatus <> 1

	select @IDPosicion = MIN(IDPosicion) from @tempPosiciones

	while exists (select top 1 1 from @tempPosiciones where IDPosicion >= @IDPosicion)
	begin

		EXEC [App].[INotificacionModuloPosiciones]0, @IDPosicion,'CREATE-AUTORIZA'
		select @IDPosicion = MIN(IDPosicion) from @tempPosiciones where IDPosicion > @IDPosicion
	end
GO
