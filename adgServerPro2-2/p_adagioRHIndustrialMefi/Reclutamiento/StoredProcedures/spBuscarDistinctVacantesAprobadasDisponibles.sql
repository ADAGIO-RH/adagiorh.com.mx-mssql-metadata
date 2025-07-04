USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Reclutamiento].[spBuscarDistinctVacantesAprobadasDisponibles] (
	@UUID Varchar(MAX) = ''
	,@PageNumber int = 1
	,@PageSize int = 2147483647
	,@query    varchar(100) = ''
)
AS
BEGIN
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	   ,@IDUsuarioAdmin int
	;

	select @IDUsuarioAdmin = cast(Valor as int) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
	
		declare @tblVacantes as table (
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
			IDReclutador int,
			ClaveReclutador varchar(20),
			NombreReclutador varchar(Max),
			ExisteFotoReclutador bit,
			InicialesReclutador varchar(5),
            TotalPaginas int,
            TotalRows int            
	)

	--exec [RH].[spBuscarPosiciones] @StringFiltroEstatus='2',@query='', @IDUsuario=1


	insert into @tblVacantes
	exec [RH].[spBuscarPosiciones] @StringFiltroEstatus='2',@query=@query, @IDUsuario=@IDUsuarioAdmin

	--update @tblVacantes
	--	set DisponibleHasta = '9999-12-31'
	--where DisponibleHasta is null

	if object_id('tempdb..#tempVacantesDisponibles_3ER3') is not null drop table #tempVacantesDisponibles_3ER3

	select 
		IDPosicion,
		IDPlaza,
		CodigoPlaza,
		IDPuesto,
		Plaza,
		UUID,
		DisponibleDesde,
		isnull(DisponibleHasta, '9999-12-31') as DisponibleHasta,
		FechaRegEstatus,
		ROW_NUMBER()OVER(PARTITION BY IDPlaza order by Plaza) as RN
	INTO #tempVacantesDisponibles_3ER3
	from @tblVacantes

	delete #tempVacantesDisponibles_3ER3 where RN > 1

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempVacantesDisponibles_3ER3
	WHERE ((UUID = @UUID)OR ISNULL(@UUID,'') = '')

	select @TotalRegistros = cast(COUNT([IDPosicion]) as decimal(18,2)) 
	from #tempVacantesDisponibles_3ER3		
	WHERE ((UUID = @UUID)OR ISNULL(@UUID,'') = '')

	select * 
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempVacantesDisponibles_3ER3 
	WHERE ((UUID = @UUID)OR ISNULL(@UUID,'') = '')
	order by Plaza asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
