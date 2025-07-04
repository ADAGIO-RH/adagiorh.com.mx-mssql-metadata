USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		:
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-03-26
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBuscarOneOrganigramasPosiciones] (
	@IDOrganigramaPosicion int = 0	,
    @CodigoPlaza varchar(10) = null,
	@IDUsuario int    	
) as
	SET FMTONLY OFF;  
    declare @IDIdioma varchar(20) ;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

    DECLARE @dtOrganitrama as table(
        ClaveColaborador varchar(100) default '', 
        Codigo VARCHAR(100) default '',
        CodigoParent VARCHAR(100) default '',
        Colaborador VARCHAR(100) default '',
        ColaboradorNombre VARCHAR(100) default '',
        Estatus varchar(100) default '',
        IDEmpleado int , 
        IDEstatus int ,
        IDPlaza int ,
        IDPosicion int ,
        Posicion VARCHAR(100) default '',
        PosicionDescripcion VARCHAR(100) default '',
        id int ,
        img VARCHAR(100) default '',                   
        pid int,         
        EsAsistente bit     ,
        IDPuesto int,        
        Temporal BIT   ,
        IDNivelEmpresarial int,
        NombreNivelEmpresarial varchar(255),
        OrdenNivelEmpresarial int
    )
    
    declare @json varchar (max)
    select @json=Data from rh.tblOrganigramasPosiciones where IDOrganigramaPosicion = @IDOrganigramaPosicion

    insert into @dtOrganitrama(IDPosicion,IDEmpleado,IDEstatus,pid,EsAsistente,IDPuesto,Codigo,Temporal,IDNivelEmpresarial)
    select * FROM   OPENJSON(@json) with (
                    IDPosicion int ,
	                IDEmpleado int ,
                    IDEstatus int ,                    
                    pid int  ,
                    EsAsistente bit,
                    IDPuesto int , 
                    Codigo varchar(10),
                    Temporal BIT,
                    IDNivelEmpresarial int
    )    
    
    if(@CodigoPlaza is not null )
    begin
         
         delete from @dtOrganitrama where isnull(Codigo,'') <> @CodigoPlaza        
         
    end

    
    update dt
        set dt.ClaveColaborador = case when dt.IDEmpleado = 0 then 'Sin Asignar' else e.ClaveEmpleado  end ,
        dt.Codigo = p.Codigo,
        dt.CodigoParent = '',
        dt.Colaborador  = case when dt.IDEmpleado = 0 then 'Sin Asignar' else concat(e.ClaveEmpleado,' - ',e.NOMBRECOMPLETO)  end ,
        dt.ColaboradorNombre = case when dt.IDEmpleado = 0 then 'Sin Asignar' else E.NOMBRECOMPLETO  end ,
        dt.Estatus = isnull(estatus.Catalogo,'Sin estatus'),
        dt.Posicion = concat(p.Codigo, ' - ',JSON_VALUE(pp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),
        dt.PosicionDescripcion = JSON_VALUE(pp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),
        dt.img = case when fe.IDEmpleado is null then 'Fotos/nofoto.jpg' else concat('Fotos/Empleados/',fe.ClaveEmpleado,'.jpg')  end ,
        dt.EsAsistente = plazas.EsAsistente,
        dt.NombreNivelEmpresarial=ISNULL(tnivelEmpresarial.Nombre,''),
        dt.OrdenNivelEmpresarial=ISNULL(tnivelEmpresarial.Orden,0),
        dt.id=dt.IDPosicion
    from @dtOrganitrama dt 
    left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = dt.IDEmpleado  
    left join [RH].[tblEmpleadosMaster] e on e.IDEmpleado=dt.IDEmpleado
    left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = dt.IDEstatus and estatus.IDTipoCatalogo = 5
    left join [RH].[tblCatPosiciones] p on p.IDPosicion=dt.IDPosicion
    left join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = p.IDPlaza
    left join  RH.tblCatPuestos pp on pp.IDPuesto=plazas.IDPuesto
    LEFT JOIN RH.tblCatNivelesEmpresariales tnivelEmpresarial on tnivelEmpresarial.IDNivelEmpresarial=dt.IDNivelEmpresarial
    where dt.Temporal is null

    
    update dt   
        set dt.ClaveColaborador = case when dt.IDEmpleado = 0 then 'Sin Asignar' else e.ClaveEmpleado  end ,        
        dt.CodigoParent = '',
        dt.Colaborador  = case when dt.IDEmpleado = 0 then 'Sin Asignar' else concat(e.ClaveEmpleado,' - ',e.NOMBRECOMPLETO)  end ,
        dt.ColaboradorNombre = case when dt.IDEmpleado = 0 then 'Sin Asignar' else E.NOMBRECOMPLETO  end ,
        dt.Estatus = isnull(estatus.Catalogo,'Sin estatus'),
        dt.Posicion = concat(dt.Codigo, ' - ',JSON_VALUE(pp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),
        dt.PosicionDescripcion = JSON_VALUE(pp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),
        dt.img = case when fe.IDEmpleado is null then 'Fotos/nofoto.jpg' else concat('Fotos/Empleados/',fe.ClaveEmpleado,'.jpg')  end ,
        dt.EsAsistente = dt.EsAsistente,
        dt.NombreNivelEmpresarial=ISNULL(tnivelEmpresarial.Nombre,''),
        dt.OrdenNivelEmpresarial=ISNULL(tnivelEmpresarial.Orden,0),
        dt.id=dt.IDPosicion
    from @dtOrganitrama dt 
    left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = dt.IDEmpleado  
    left join [RH].[tblEmpleadosMaster] e on e.IDEmpleado=dt.IDEmpleado
    left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = dt.IDEstatus and estatus.IDTipoCatalogo = 5        
    LEFT JOIN RH.tblCatNivelesEmpresariales tnivelEmpresarial on tnivelEmpresarial.IDNivelEmpresarial=dt.IDNivelEmpresarial
    left join  RH.tblCatPuestos pp on pp.IDPuesto=dt.IDPuesto
    where dt.Temporal = 1

    select 
        IDOrganigramaPosicion,
        Nombre,
        (
            select * from ( select * from @dtOrganitrama) info for json auto
        ) As Data	
	from rh.tblOrganigramasPosiciones
    where  IDOrganigramaPosicion = @IDOrganigramaPosicion
GO
