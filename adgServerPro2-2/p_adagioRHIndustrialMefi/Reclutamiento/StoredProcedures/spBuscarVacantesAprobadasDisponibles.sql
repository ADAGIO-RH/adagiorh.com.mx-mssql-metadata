USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--[Reclutamiento].[spBuscarVacantesAprobadasDisponibles] 
--GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-24
-- Description:	sp para consultar los autorizados
-- [Reclutamiento].[spBuscarVacantesAprobadasDisponibles]
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarVacantesAprobadasDisponibles] 
	(
	 @IDPosicion int = 0
	,@IDPlaza int = 0
	,@IDCliente int = 0
	,@UUID Varchar(MAX) = ''
	,@IDUsuario int = null     
	,@PageNumber int = 1
	,@PageSize int = 2147483647
	,@query    varchar(100) = ''
	)
AS
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;

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
            TotalPaginas int,
            TotalRows int            
	)

	insert into @tblVacantes
	exec
	[RH].[spBuscarPosiciones] @IDPosicion= @IDPosicion,@IDPlaza=@IDPlaza,@IDCliente=@IDCliente,@query=@query, @IDUsuario=@IDUsuario

	update @tblVacantes
		set DisponibleHasta = '9999-12-31'
	where DisponibleHasta is null


	DELETE @tblVacantes
	WHERE IDEstatus <> 2
	
	

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tblVacantes
	WHERE ((UUID = @UUID)OR ISNULL(@UUID,'') = '')

	select @TotalRegistros = cast(COUNT([IDPosicion]) as decimal(18,2)) 
	from @tblVacantes		
	WHERE ((UUID = @UUID)OR ISNULL(@UUID,'') = '')

	select * 
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tblVacantes 
	WHERE ((UUID = @UUID)OR ISNULL(@UUID,'') = '')
	order by Plaza asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
