USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp obtiene la información de los empleados de la plaza, obteniendo una comparacion 
                        de sus configuraciones.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com
** FechaCreacion	: 2023-01-08
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarPlazaDetalleEmpleados]
    @IDPlaza int,
    @IDUsuario int,
    @BanderaTotal bit
AS
BEGIN
    declare  	   
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    DECLARE @json varchar(max),
    @QuerySelect varchar(max)

    declare @dtConfiguraciones as table(
        NombreConfiguracion varchar(255),
        Valor VARCHAR(255),
        Descripcion VARCHAR(255),
        NameKey VARCHAR(100),
        RowNumber int
    )

    declare @dtEmpleados as table(
        IDEmpleado int ,
        ClaveEmpleado varchar(100),
        NombreCompleto varchar(100),
        IDDepartamento int,        
        IDSucursal INT,
        IDTipoPrestacion int ,
        IDRegPatronal int ,
        IDEmpresa int ,
        IDCentroCosto int ,
        IDArea int ,
        IDDivision int,
        IDRegion int ,
        IDClasificacionCorporativa int,
        IDPerfil int,
        IDPuesto int , 
        Departamento varchar(200),        
        Sucursal varchar(200),
        TipoPrestacion varchar(200) ,
        RegPatronal varchar(200) ,
        Empresa varchar(200) ,
        CentroCosto varchar(200) ,
        Area varchar(200) ,
        Division varchar(200),
        Region varchar(200) ,
        ClasificacionCorporativa varchar(200),
        Perfil  varchar(200),
        Puesto  varchar(200),
        IDPosicion int,
        Iniciales varchar(6)
    )

    SELECT @json=Configuraciones
    from rh.tblCatPlazas
    where IDPlaza=@IDPlaza

    insert into @dtConfiguraciones
        (NombreConfiguracion,Valor,Descripcion,NameKey,RowNumber)
    select
        ctcp.Nombre as TipoConfiguracionPlaza		                
        , t.Valor      				 
            , ff.descripcion               
            , JSON_VALUE(Configuracion,'$.fieldValue')
            , ROW_NUMBER()over(order by Orden)
    from [RH].[tblCatTiposConfiguracionesPlazas] ctcp with (nolock)
        left join (
            SELECT IDTipoConfiguracionPlaza, Valor
        FROM OPENJSON(@json )
                WITH (   
                    IDTipoConfiguracionPlaza   varchar(200) '$.IDTipoConfiguracionPlaza' ,                
                    Valor int          '$.Valor' 
                )                     
        ) as t on t.IDTipoConfiguracionPlaza = ctcp.IDTipoConfiguracionPlaza    
    outer APPLY 
        [RH].[fnGetValueMemberFromTable](ctcp.TableName,t.Valor)  as ff
    where 
        ctcp.Disponible=1 and ctcp.IDTipoConfiguracionPlaza<>'PosicionJefe'
    order by ctcp.Orden

    insert into @dtConfiguraciones (NombreConfiguracion,Valor,Descripcion,NameKey,RowNumber)
    select 'Puesto',plaza.IDPuesto,JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'IDPuesto',12 
        from rh.tblCatPlazas  plaza
    inner join rh.tblCatPuestos puesto on puesto.IDPuesto=plaza.IDPuesto
    where IDPlaza=@IDPlaza
    
    

    insert into @dtEmpleados
        (IDEmpleado,ClaveEmpleado,NombreCompleto,[IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa],[IDPerfil],IDPuesto,
            [Departamento], [Sucursal], [TipoPrestacion], [RegPatronal], [Empresa], [CentroCosto], [Area], [Division], [Region], [ClasificacionCorporativa],[Perfil],Puesto,IDPosicion,Iniciales)
    select m.IDEmpleado,ClaveEmpleado, NOMBRECOMPLETO, IDDepartamento, IDSucursal, IDTipoPrestacion, IDRegPatronal, IDEmpresa, IDCentroCosto, IDArea, IDDivision, IDRegion, IDClasificacionCorporativa,u.IDPerfil,plaza.IDPuesto,
            Departamento, Sucursal, m.TiposPrestacion, RegPatronal, Empresa, CentroCosto, Area, Division, Region, ClasificacionCorporativa,p.Descripcion, JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')), cp.IDPosicion,
            SUBSTRING(coalesce(m.Nombre, ''), 1, 1)+SUBSTRING(coalesce(m.Paterno, coalesce(m.Materno, '')), 1, 1) 
    From rh.tblCatPosiciones cp
        inner join rh.tblCatPlazas plaza on plaza.IDPlaza=cp.IDPlaza
        inner join rh.tblCatPuestos puesto on puesto.IDPuesto=plaza.IDPuesto
        inner join rh.tblEmpleadosMaster m on  m.IDEmpleado=cp.IDEmpleado 
        left join Seguridad.tblUsuarios u on u.IDEmpleado=m.IDEmpleado
        left join Seguridad.tblCatPerfiles p on p.IDPerfil= u.IDPerfil
        
    where cp.IDPlaza=@IDPlaza



    insert into @dtEmpleados
        (ClaveEmpleado,[IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa],[IDPerfil],[IDPuesto])
    SELECT 'Plaza' AS ClaveEmpleado,
        [IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa],[IDPerfil],[IDPuesto]
    FROM
        (SELECT Valor, NameKey
        FROM @dtConfiguraciones) AS SourceTable
    PIVOT
    (
        max(Valor)
        FOR NameKey IN ([IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa],[IDPerfil],[IDPuesto])
    ) AS PivotTable

    

    if  @BanderaTotal =0  
    BEGIN

        SELECT de.IDEmpleado,de.ClaveEmpleado,
            de.NombreCompleto,
            IIF(de.IDDepartamento=dd.IDDepartamento,1,0) as [1], --[Departamento],
            IIF(de.IDSucursal=dd.IDSucursal,1,0) as [2], --[Sucursal],
            IIF(de.IDTipoPrestacion=dd.IDTipoPrestacion,1,0) [3] , --as [Prestaciones],
            IIF(de.IDRegPatronal=dd.IDRegPatronal,1,0) as [4], --[Registro Patronal],
            IIF(de.IDEmpresa=dd.IDEmpresa,1,0) as [5], --[Empresa],
            IIF(de.IDCentroCosto=dd.IDCentroCosto,1,0) as [6], --[Centro de Costo],
            IIF(de.IDArea=dd.IDArea,1,0) as [7], --[Area],
            IIF(de.IDDivision=dd.IDDivision,1,0) as [8], --[Division],
            IIF(de.IDRegion=dd.IDRegion,1,0) [9] , --as [Región],
            IIF(de.IDClasificacionCorporativa=dd.IDClasificacionCorporativa,1,0) [10],--as [Clasificación Corporativa]
            IIF(de.IDPerfil=dd.IDPerfil,1,0) [11],--as [Perfil]
            IIF(de.IDPuesto=dd.IDPuesto,1,0) [12],--as [Perfil]

            de.Departamento as [d1], --[Departamento],
            de.Sucursal as [d2], --[Sucursal],
            de.TipoPrestacion [d3] , --as [Prestaciones],
            de.RegPatronal as [d4], --[Registro Patronal],
            de.Empresa as [d5], --[Empresa],
            de.CentroCosto as [d6], --[Centro de Costo],
            de.Area as [d7], --[Area],
            de.Division as [d8], --[Division],
            de.Region [d9] , --as [Región],
            de.ClasificacionCorporativa [d10],--as [Clasificación Corporativa]
            de.Perfil [d11],--as [Perfil]
            de.Puesto [d12],--as [Perfil]
            de.IDPosicion,
            de.Iniciales
        FROM @dtEmpleados de
            inner join @dtEmpleados dd on dd.ClaveEmpleado='Plaza'                        
        where de.ClaveEmpleado!='Plaza'

    end
    else 
    begin
    
        select 
            RowNumber,
            NombreConfiguracion,
            isnull(conf.Descripcion,'- No asignado -') as Descripcion,
            isnull(valueConfig,0) as [Total]
            
        From @dtConfiguraciones  conf
            left join (     
                    select
                indexConfig,
                valueConfig
            from ( SELECT
                    sum(IIF(de.IDDepartamento=dd.IDDepartamento,1,0)) as [1], --[Departamento],
                    sum(IIF(de.IDSucursal=dd.IDSucursal,1,0)) as [2], --[Sucursal],
                    sum(IIF(de.IDTipoPrestacion=dd.IDTipoPrestacion,1,0)) [3] , --as [Prestaciones],
                    sum(IIF(de.IDRegPatronal=dd.IDRegPatronal,1,0)) as [4], --[Registro Patronal],
                    sum(IIF(de.IDEmpresa=dd.IDEmpresa,1,0)) as [5], --[Empresa],
                    sum(IIF(de.IDCentroCosto=dd.IDCentroCosto,1,0)) as [6], --[Centro de Costo],
                    sum(IIF(de.IDArea=dd.IDArea,1,0)) as [7], --[Area],
                    sum(IIF(de.IDDivision=dd.IDDivision,1,0)) as [8], --[Division],
                    sum(IIF(de.IDRegion=dd.IDRegion,1,0)) [9] , --as [Región],
                    sum(IIF(de.IDClasificacionCorporativa=dd.IDClasificacionCorporativa,1,0)) [10],--as [Clasificación Corporativa]
                    sum(IIF(de.IDPerfil=dd.IDPerfil,1,0)) [11],--as [Perfil]
                    sum(IIF(de.IDPuesto=dd.IDPuesto,1,0)) [12]--as [Puesto]
                FROM @dtEmpleados de
                    inner join @dtEmpleados dd on dd.ClaveEmpleado='Plaza'
                where de.ClaveEmpleado!='Plaza'
        ) as tabla
            unpivot
        (
            valueConfig
            for indexConfig in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
        ) unpiv) tblTotal on tblTotal.indexConfig=conf.RowNumber;
    end

END
GO
