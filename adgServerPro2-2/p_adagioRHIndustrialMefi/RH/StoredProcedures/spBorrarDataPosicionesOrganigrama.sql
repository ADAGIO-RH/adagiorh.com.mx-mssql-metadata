USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Borrar JSON de la tabla  rh.tblOrganigramasPosiciones
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-03-30
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBorrarDataPosicionesOrganigrama] (
	@IDOrganigramaPosicion int , 
    @IDPosicion int ,
    @ConfirmadoEliminar bit ,
    @IDUsuario int 	    
) as
	SET  FMTONLY OFF;  
    DECLARE @dtOrganitrama as table(    
        IDPosicion int ,
        IDEmpleado int ,
        IDEstatus int ,
        pid int  ,
        EsAsistente bit,        
        Codigo varchar(10),
        Temporal bit,
        IDPuesto int  
    );

    DECLARE @dtPosicionEliminar as table(    
        IDPosicion int ,
        Codigo varchar(10),
        Descripcion varchar(150),
        pid int  ,
        TotalPosiciones int  ,
        IDPuesto int         ,
        RowNumber int
    );

    declare @json varchar(max)
    select @json=[Data] from rh.tblOrganigramasPosiciones     where IDOrganigramaPosicion=@IDOrganigramaPosicion      

    


    insert into @dtOrganitrama
    select * FROM  OPENJSON(@json) with (
                IDPosicion int ,
                IDEmpleado int ,
                IDEstatus int ,                    
                pid int  ,
                EsAsistente bit,                
                Codigo varchar(10),
                Temporal BIT ,
                IDPuesto int  
    );             

    update  dt
            set dt.IDPuesto = plazas.IDPuesto,
            Codigo= pp.Codigo
     from  @dtOrganitrama dt    
        inner join rh.tblCatPosiciones pp on pp.IDPosicion = dt.IDPosicion
        inner join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = pp.IDPlaza




    ;With CteChildsPlazas   
	As    
	(            
		select p.IDPosicion , p.Codigo, JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion, p.pid, p.IDPuesto
		from @dtOrganitrama p 
			inner join RH.tblCatPuestos puestos on puestos.IDPuesto = p.IDPuesto
		where  p.IDPosicion =@IDPosicion
		union All    
		select p.IDPosicion , p.Codigo, JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion, p.pid, p.IDPuesto
		from @dtOrganitrama p 
		inner join RH.tblCatPuestos puestos on puestos.IDPuesto = p.IDPuesto
			Inner Join CteChildsPlazas pc On pc.IDPosicion  = p.pid
	)  
	insert @dtPosicionEliminar (IDPosicion,Codigo,Descripcion, pid,TotalPosiciones,IDPuesto,RowNumber)
	select *
	from (
		select  p.IDPosicion,p.Codigo, p.Descripcion as Nombre, p.pid,COUNT(p.IDPosicion) as TotalPosiciones , P.IDPuesto, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS ROWNUMBER
		from CteChildsPlazas p 					
        group by p.IDPosicion,p.Codigo, p.Descripcion,p.pid, p.IDPuesto
	) d
	order by TotalPosiciones desc, d.Nombre
	OPTION (MAXRECURSION 1000);  

    if @ConfirmadoEliminar =0 
    BEGIN
            declare @HTMLMessage VARCHAR(max),
                    @HTMLListOut varchar(max),
                    @RowTempalte varchar(max);

            set @RowTempalte ='<tr>'+
                                '<th>%i</th>'+
                                '<th>%s</th>'+                                                                
                            '</tr>';

            set @HTMLListOut=''
            set @HTMLMessage='<b style="color:darkred">NOTA: Al eliminar algúna posición, tambien se eliminaran sus respectivos hijos.</b><br>'+
                                '<style>'+
                                    '.tbleliminar {'+
                                        'width: [WIDTH_TABLE];'+
                                    '}'+
                                    '.tbleliminar td, th {'+
                                        'border: 1px solid #dddddd;'+
                                        'text-align: left;'+
                                        'padding: 8px;'+
                                        'font-weight: inherit;'+
                                    '}'+
                                '</style>'+
                                '<table class="tbleliminar" >    '+
                                    '<tr>'+
                                        '<th colspan="4" >'+
                                            '<div style="text-align: center;"><b>Información Detallada</b></div>            '+
                                        '</th>        '+
                                    '</tr>    '+
                                    '<tr>'+
                                        '<th>*</th>'+
                                        '<th>Plaza</th>'+                                                                                
                                    '</tr>    '+
                                    '[BODY_TABLE]'+
                                '</table>';
                                                                  
            select @HTMLListOut = @HTMLListOut + FORMATMESSAGE(@RowTempalte,RowNumber,(ep.Codigo  + ' - ' + ep.Descripcion))
	        FROM @dtPosicionEliminar ep            
        
            select REPLACE(replace(TRIM(@HTMLMessage),'[BODY_TABLE]',@HTMLListOut),'[WIDTH_TABLE]','100%') as [Mensaje], 1 IDTipoRespuesta,  @IDPosicion ID , @IDPosicion as IDS
            -- select FormatMessage(TRIM(@HTMLMessage),'100%',@HTMLListOut) as [Mensaje], 1 IDTipoRespuesta,  @IDPosicion ID , @IDPosicion as IDS
            
    END else 
    BEGIN
                        
        delete dt    
            from @dtOrganitrama  dt
        where dt.IDPosicion in (select IDPosicion  From @dtPosicionEliminar)

        update rh.tblOrganigramasPosiciones set 
            Data = ( select * from ( select * from @dtOrganitrama) info for json auto )     
        where IDOrganigramaPosicion = @IDOrganigramaPosicion        
    
        select 'El estatus de la plaza se modifico correctamente.' as [Mensaje], 0 IDTipoRespuesta, @IDPosicion ID, (SELECT STRING_AGG(IDPosicion, ', ') from @dtPosicionEliminar )as IDS

    END
    -- exec [RH].[spBorrarDataPosicionesOrganigrama] @IDOrganigramaPosicion=17, @IDPosicion=3,@IDUsuario= 1 ,@ConfirmadoEliminar=0        
GO
