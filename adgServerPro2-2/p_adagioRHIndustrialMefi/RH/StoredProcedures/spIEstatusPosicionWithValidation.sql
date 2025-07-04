USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: SP PARA PERMITIR CAMBIAR EL ESTATUS DE LA POSICION -> TOMANDO EN CUENTA LOS HIJOS                     
** Autor			: Jose vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-11-02
** Paremetros		: 
	 

** Notas: Temp table @tempResponse - TipoRespuesta  
  -1 - Sin respuesta  
   0 - Eliminado  
   1 - EsperaDeConfirmación  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	    Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2023-11-09              ANEUDY ABREU    Corrige parámetro al SP [RH].[spActualizarTotalesPosiciones]
***************************************************************************************************/
CREATE proc [RH].[spIEstatusPosicionWithValidation]
(
	@IDPosicion int,
	@ConfirmadoEliminar bit = 0 ,
    @IDEstatus int ,
	@IDUsuario int,
    @printResult bit =1
) as

	SET ANSI_WARNINGS OFF
    declare
		@IDTipoCatalogoEstatusPosiciones int = 5,	
		@TotalDePosiciones int = 0,
		@mensajeConfirmar varchar(max) = '',
		@mensajePlazasEliminadas varchar(100) = '',
		@OldJSON varchar(max),
		@NewJSON varchar(max),
        @IDPlaza int
	;

	select @IDPlaza = IDPlaza
	from RH.tblCatPosiciones
	where IDPosicion = @IDPosicion
  
    declare @TablaPosiciones as table (
        IDPosicion int,
        IDPlaza int,
        IDEstatus int ,
        IDEmpleado int,
        Codigo VARCHAR(20),
        RowNumber int ,
        DescripcionPlaza varchar(100),
        Empleado varchar(100)
    )

    declare @tempEstatusPosiciones as table (
		IDEstatusPosicion int,
		IDPosicion int,
		IDEstatus int,
		Estatus varchar(255),
		DisponibleDesde date,
		DisponibleHasta date,
		IDUsuario int,
		FechaReg datetime,
        ConfiguracionStatus nvarchar(max),
		[ROW] int
	)
    
    ;With CteChildsPosiciones
	As    
	(            
        SELECT  IDPosicion,
                IDPlaza as [Plaza],
                p.IDEmpleado [IDEmpleado] ,
                p.Codigo [Codigo]                
            From [RH].[tblCatPosiciones] p
        WHERE p.IDPosicion= @IDPosicion
        UNION ALL
        SELECT  p.IDPosicion,
                p.IDPlaza as [Plaza],
                p.IDEmpleado [IDEmpleado]  ,
                p.Codigo [Codigo]                
            From [RH].[tblCatPosiciones] p
        INNER JOIN CteChildsPosiciones pc On pc.IDPosicion  = p.ParentId        		
	)  
    insert into @TablaPosiciones (IDPosicion,IDPlaza,IDEmpleado,RowNumber,Codigo)
    select IDPosicion,Plaza,IDEmpleado,ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),Codigo  from CteChildsPosiciones
    OPTION (MAXRECURSION 1000);  

    
    if ( (select count(*) from @TablaPosiciones ) =1 )        
	BEGIN
            update rh.tblCatPosiciones set IDEmpleado =NULL WHERE IDPosicion=@IDPosicion
            
            insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
	        select @IDPosicion,@IDEstatus,@IDUsuario,null

            EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario			  
            if @printResult =1 
            begin 
                select 'El estatus de la posición se modifico correctamente.' as [Mensaje], 0 IDTipoRespuesta, @IDPosicion ID
            end
	END ELSE 
    BEGIN

        insert @tempEstatusPosiciones
	    select 
    		isnull(estatusPosiciones.IDEstatusPosicion,0) AS IDEstatusPosicion
		    ,posiciones.IDPosicion
		    ,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		    ,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
    		,isnull(estatusPosiciones.DisponibleDesde, '1990-01-01') as DisponibleDesde
		    ,isnull(estatusPosiciones.DisponibleHasta, '1990-01-01') as DisponibleHasta
		    ,isnull(estatusPosiciones.IDUsuario,0) as IDUsuario
		    ,isnull(estatusPosiciones.FechaReg,'1990-01-01') FechaReg
            ,isnull(estatus.configuracion,'') as ConfiguracionStatus
		    ,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							    ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
        from @TablaPosiciones posiciones
            left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
            left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones
                        
        UPDATE p SET IDEstatus=e.IDEstatus
            FROM @TablaPosiciones p
        INNER JOIN @tempEstatusPosiciones e on e.IDPosicion=p.IDPosicion and e.[ROW]=1

        update p set DescripcionPlaza= concat(pl.Codigo,' - ',JSON_VALUE(pp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')))
            FROM @TablaPosiciones p
        inner join rh.tblCatPlazas pl on pl.IDPlaza= p.IDPlaza
        inner join rh.tblCatPuestos pp on pp.IDPuesto = pl.IDPuesto

        UPDATE p set Empleado = isnull(m.NOMBRECOMPLETO,'N/A')
            FROM @TablaPosiciones p 
        left join RH.tblEmpleadosMaster m on m.IDEmpleado= p.IDEmpleado

        IF (@ConfirmadoEliminar = 0)
        begin 
            declare @HTMLMessage VARCHAR(max),
                    @HTMLListOut varchar(max),
                    @RowTempalte varchar(max);

            set @RowTempalte ='<tr>'+
                                '<th>%i</th>'+
                                '<th>%s</th>'+
                                '<th>%s</th>'+
                                '<th>%s</th>'+
                            '</tr>';

            set @HTMLListOut=''

            set @HTMLMessage='<b style="color:darkred">NOTA: Esta posición contiene hijos, al modificar el estatus de esta posición se modificaran los hijos.</b><br>'+
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
                                        '<th>Código</th>'+
                                        '<th>Plaza</th>'+
                                        '<th>Empleado</th>'+
                                    '</tr>    '+
                                    '[BODY_TABLE]'+
                                '</table>'
                        

            select @HTMLListOut = @HTMLListOut + 
		                            FORMATMESSAGE(@RowTempalte,  ep.RowNumber,ep.Codigo,ep.DescripcionPlaza,ep.Empleado)
	        FROM @TablaPosiciones ep            

            select REPLACE(replace(TRIM(@HTMLMessage),'[BODY_TABLE]',@HTMLListOut),'[WIDTH_TABLE]','100%') as [Mensaje], 1 IDTipoRespuesta,  @IDPosicion ID 
        END else 
        begin 
            declare  @total  int
            declare @row int
            select  @total=count(*) from @TablaPosiciones                
            set @row=1                                            
            while (@row <=@total)
            BEGIN                
                declare @IDPosicionTemp int 

                select @IDPosicionTemp =IDPosicion
                    from @TablaPosiciones where RowNumber= @row

                update rh.tblCatPosiciones set IDEmpleado =NULL WHERE IDPosicion=@IDPosicionTemp

                insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
	            select @IDPosicionTemp,@IDEstatus,@IDUsuario,null

                EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario	

                set @row=@row+1;
            end

            if @printResult =1
            begin 
                select 'Los estatus de las posiciones se han modificado correctamente.' as [Mensaje], 0 IDTipoRespuesta, @IDPosicion ID
            end
            
        end
    END
GO
