USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIniciarProcesoAutorizacionPosicionesPorPlaza](
	@IDPlaza int,
	@IDUsuario int
) as
	declare @IDPosicion int;

	declare @tempPosiciones as table (
			IDPosicion int,
		    IDPlaza int,
		    CodigoPlaza varchar(50),
		    IDPuesto int,
    		Plaza varchar(max),
            IDCliente int,
            Cliente varchar(max),
            Codigo varchar(max),
            ParentId int,
            ParentCodigo varchar(max),
            Temporal bit,
            DisponibleDesde datetime,
            DisponibleHasta datetime,
            UUID Varchar(MAX),
            IDEmpleado int,
            ClaveEmpleado varchar(max),
            Colaborador varchar(max),
            ExisteFotoColaborador bit,
            IDEstatusPosicion int,
            IDEstatus int,
            Estatus varchar(max),
            IDUsuario int,
            ConfiguracionStatus varchar(max),
            FechaRegEstatus datetime,
            Iniciales Varchar(20),
            EsAsistente bit,
            IDNivelEmpresarial int,            
            NombreNivelEmpresarial varchar(255),
            OrdenNivelEmpresarial int     ,  
            IDOrganigrama int,
            TotalPaginas int,
            TotalRows int
            
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
