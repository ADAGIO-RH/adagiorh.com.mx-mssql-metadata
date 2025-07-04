USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: SP PARA PERMITIR CAMBIAR EL ESTATUS DE LAS PLAZAS -> TOMANDO EN CUENTA LOS HIJOS                     
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
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [RH].[spIEstatusPlazaWithValidation] 
(
	@IDPlaza int,
	@ConfirmadoEliminar bit = 0 ,
    @IDEstatus int ,
	@IDUsuario int
) as

    SET ANSI_WARNINGS OFF    
   declare @tempResponse as table(  
		ID int  
		,Mensaje Nvarchar(max)  
		,TipoRespuesta int  
    );  

	declare @tempTotalPlazasPosiciones as table(
		IDPlaza int,
		Codigo	App.SMName,
		Nombre	App.MDName,
		TotalPosiciones int,
		IDPuesto int,
        RowNumber int 
    
	)

	;With CteChildsPlazas   
	As    
	(            
		select p.IDPlaza , p.Codigo, JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion, p.ParentId, p.IDPuesto
		from RH.tblCatPlazas p with (nolock)  
			inner join RH.tblCatPuestos puestos on puestos.IDPuesto = p.IDPuesto
		where p.IDPlaza = @IDPlaza     
		union All    
		select p.IDPlaza , p.Codigo,JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion  , p.ParentId , p.IDPuesto
		from RH.tblCatPlazas p with (nolock)  
		inner join RH.tblCatPuestos puestos
				on puestos.IDPuesto = p.IDPuesto
			Inner Join CteChildsPlazas pc On pc.IDPlaza  = p.ParentId
	)  
	insert @tempTotalPlazasPosiciones
	select * ,ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
	from (
		select  p.IDPlaza,p.Codigo, p.Descripcion as Nombre, COUNT(po.IDPosicion) as TotalPosiciones , P.IDPuesto
		from CteChildsPlazas p 
			left join [RH].[tblCatPosiciones] po on po.IDPlaza = p.IDPlaza
			inner join RH.tblCatPuestos puestos
				on puestos.IDPuesto = p.IDPuesto
		group by p.IDPlaza,p.Codigo, p.Descripcion, p.IDPuesto
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
                                '<th class="d-flex justify-content-center"">%i</th>'+
                            '</tr>';

            set @HTMLListOut=''
            set @HTMLMessage='<b style="color:darkred">NOTA: Al cambiar el estatus algúna plaza, tambien se modificaran los estatus de sus posiciones y sus respectivos hijos.</b><br>'+
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
                                '<table class="tbleliminar">'+
                                    '<tr>'+
                                        '<th colspan="4" >'+
                                            '<div style="text-align: center;"><b>Información Detallada</b></div>'+
                                        '</th>        '+
                                    '</tr>    '+
                                    '<tr>'+
                                        '<th>*</th>'+
                                        '<th>Plaza</th>'+                                        
                                        '<th style="width:50px">T.Posiciones</th>'+
                                    '</tr>'+
                                    '[BODY_TABLE]'+
                                '</table>';
                        

            select @HTMLListOut = @HTMLListOut + 
		                            FORMATMESSAGE(@RowTempalte,  ep.RowNumber,(ep.Codigo  + ' - ' + ep.Nombre),ep.TotalPosiciones)
	        FROM @tempTotalPlazasPosiciones ep            

            -- select FormatMessage(TRIM(@HTMLMessage),'100%',@HTMLListOut) as [Mensaje], 1 IDTipoRespuesta,  @IDPlaza ID
            select REPLACE(replace(TRIM(@HTMLMessage),'[BODY_TABLE]',@HTMLListOut),'[WIDTH_TABLE]','100%') as [Mensaje], 1 IDTipoRespuesta,  @IDPlaza ID
            
    END else 
    BEGIN
        declare @TotalPosicion INT,
                @IDPlazaTemp int ;                    

        select 
            @TotalPosicion= s.TotalPosiciones,
            @IDPlazaTemp =s.IDPlaza
        FROM @tempTotalPlazasPosiciones s
        where RowNumber=1

                
        
        INSERT INTO RH.tblEstatusPlazas (IDPlaza,IDEstatus,IDUsuario)
        SELECT IDPlaza,@IDEstatus,@IDUsuario   from @tempTotalPlazasPosiciones
                

        declare @tempPosiciones as table(
            IDPosicion int,
            RowNumber int
        )

        insert into @tempPosiciones (IDPosicion,RowNumber)
        select IDPosicion,ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) from rh.tblCatPosiciones where IDPlaza=@IDPlazaTemp

        

        declare  @total  int
        declare @row int
        select  @total=count(*) from @tempPosiciones                
        set @row=1                                            
        while (@row <=@total)
        BEGIN                
            declare @IDPosicionTemp int ,
                    @IDEstatusPosicion int


            set @IDEstatusPosicion = case when @IDEstatus = 3 then 4
                when @IDEstatus = 5 then 6
                else @IDEstatus end -- El cancelado de la plaza es 3 pero en la posicion el cancelar es 4, el autorizar para los 2 es mismo
            


            select @IDPosicionTemp =IDPosicion
                from @tempPosiciones where RowNumber= @row
            
            exec [RH].[spIEstatusPosicionWithValidation] 
                @IDPosicion =@IDPosicionTemp,
                @ConfirmadoEliminar = 1 ,
                @IDEstatus = @IDEstatusPosicion ,
                @IDUsuario =@IDUsuario,
                @printResult=0

            set @row=@row+1;
        end        

        select 'El estatus de la plaza se modifico correctamente.' as [Mensaje], 0 IDTipoRespuesta, @IDPlaza ID

    END
GO
