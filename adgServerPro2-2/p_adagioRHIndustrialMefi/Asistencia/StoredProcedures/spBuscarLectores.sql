USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [d_adagioRH]
--GO
--/****** Object:  StoredProcedure [Asistencia].[spBuscarLectores]    Script Date: 22/06/2022 04:07:34 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS LECTORES
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              


[Asistencia].[spBuscarLectores] @IDUsuario=1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-10-20			Aneudy Abreu	Se agregaron los campos IDCliente y Cliente
2022-06-10			Aneudy Abreu	Se agregó el parámetro @IDTipoLector
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarLectores](
	 @IDLector		int = null
	,@IDTipoLector	varchar(100) = null
	,@NumeroSerial	varchar(50) = null
	,@IDUsuario		int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query		varchar(max) = ''
)
AS
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#temptblLectores') is not null drop table #temptblLectores;

	SELECT 
		 L.IDLector
		,L.Lector
		,L.CodigoLector
		,L.PasswordLector
		,L.IDTipoLector
		,TL.TipoLector
		,isnull(L.IDZonaHoraria,0) as IDZonaHoraria
		,isnull(z.Name,'SIN DEFINIR') as ZonaHoraria
		,l.IP as IP
		,l.Puerto as Puerto
		,l.Estatus as Estatus
		,isnull(l.EsComedor,0) as EsComedor
		,isnull(l.Comida,0) as Comida
		,isnull(L.IDCliente,0) IDCliente
		,isnull(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),'Sin cliente asignado') as Cliente
        ,L.Master as [Master]
		,l.NumeroSerial as [NumeroSerial]
		,isnull(l.Configuracion,'{}') as Configuracion
		,isnull(d.LastSync, '1900-01-01') as FechaHoraUltimaSincronizacion
		,isnull(l.FechaHoraUltimaDescargaChecada, '1900-01-01') as FechaHoraUltimaDescargaChecada
		,(select count(*) from Asistencia.tblLectoresEmpleados le where le.IDLector = l.IDLector) as TotalEmpleadosAsignados 
		,(
			select top 5
				e.IDEmpleado, 
				e.ClaveEmpleado, 
				e.NOMBRECOMPLETO as Colaborador,
				SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1) as Iniciales,
				case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
			from Asistencia.tblLectoresEmpleados le 
				join RH.tblEmpleadosMaster e on e.IDEmpleado = le.IDEmpleado and e.Vigente = 1	
				left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = e.IDEmpleado  
			where le.IDLector = l.IDLector
			for json auto
		) TopEmpleadosAsignados
		,TL.Configuracion as ConfiguracionTipoLector
		,isnull(L.AsignarTodosLosColaboradores,0) as AsignarTodosLosColaboradores
		,CASE WHEN l.Configuracion like '%ADMS%' THEN  zkteco.fnGetQtyComandosPendientes(l.NumeroSerial)
			ELSE 0 END as ComandosPendientes
		,ROW_NUMBER()OVER(ORDER BY IDLECTOR ASC) AS ROWNUMBER
	INTO #temptblLectores
	from Asistencia.tblLectores L
		INNER JOIN Asistencia.tblCatTiposLectores TL on L.IDTipoLector = TL.IDTipoLector
		LEFT JOIN zkteco.tblDevice d on d.DevSN = l.NumeroSerial
		LEFT JOIN RH.tblCatClientes c on c.IDCliente = L.IDCliente
		LEFT JOIN Tzdb.Zones Z on Z.Id = L.IDZonaHoraria
	WHERE ((l.IDLector = @IDLector) OR (isnull(@IDLector, '') = ''))
		and ((L.IDTipoLector = @IDTipoLector) OR (isnull(@IDTipoLector, '') = ''))
		and ((L.NumeroSerial = @NumeroSerial) OR (isnull(@NumeroSerial, '') = ''))
			and (coalesce(@query,'') = '' or coalesce(L.Lector, '')+' '+coalesce(L.CodigoLector, '') like '%'+@query+'%')



	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #temptblLectores

	select @TotalRegistros = cast(COUNT(IDLector) as decimal(18,2)) from #temptblLectores		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #temptblLectores
	order by CodigoLector asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
