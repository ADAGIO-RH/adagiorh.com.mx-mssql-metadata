USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
/****************************************************************************************************       
** Descripción  : Buscar los eventos del calendario de comidas     
** Autor   : Denzel Ovando   
** Email   : denzel.ovando@adagio.com.mx      
** FechaCreacion : 2020-10-26      
** Paremetros  :  
       @FechaInicio date      
      ,@FechaFin date      
      ,@IDUsuario int      
            

****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd)    Autor   Comentario      
------------------- ------------------- ------------------------------------------------------------      

***************************************************************************************************/      
CREATE proc [Comedor].[spBuscarCalendarioComidasColaborador]--20314,'2018-09-01','2018-09-30',1    
(          
	@IDEmpleado int 
	,@FechaInicio date      
	,@FechaFin date      
	,@IDUsuario int      
) as      
      
	declare       
		@dtEventos [Asistencia].[dtEventoCalendario]  
		,@Fechas [App].[dtFechas]  
		,@dtEmpleados RH.dtEmpleados  
	;      

		insert into @Fechas(Fecha)  
		exec [App].[spListaFechas] @FechaIni = @FechaInicio, @FechaFin = @FechaFin  


	 insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor,data)      
		select
		 tp.IDPedido --id
		,tp.DescontadaDeNomina --TipoEvento
		,tp.IDEmpleado -- IDEmpleado
		,concat('Pedido #',tp.Numero, ' - $',sum(isnull(tp.GrandTotal,0.00)) ) -- title
		,1
		,CAST(tp.FechaCreacion AS DATETIME)--start
		,CAST(tp.FechaCreacion  AS DATETIME) --end	
		,null--url
		,case when tp.DescontadaDeNomina = 1 then '#FF7F00' else '#2196F3' end --color
		,null --backgroundColor
		,null --borderColor
		,null --textColor
		,sum(isnull(tp.GrandTotal,0.00))--data
			
	from 
	[Comedor].[tblPedidos] tp (nolock)
	join RH.tblEmpleados emp with (nolock) on tp.IDEmpleado = emp.IDEmpleado
	where tp.IDEmpleado = @IDEmpleado
	and tp.FechaCreacion between @FechaInicio and @FechaFin
	and tp.Cancelada = 0

	group by  
	tp.IDPedido
	,tp.Numero
	,tp.IDEmpleado
	,tp.IDRestaurante
	,tp.FechaCreacion
	,tp.DescontadaDeNomina
	

		
		
		

    
	select       
		id      
		,TipoEvento      
		,IDEmpleado      
		,title      
		,allDay      
		,start      
		,[end]      
		,url      
		,color      
		,backgroundColor      
		,borderColor      
		,textColor 
		,[data]  
	from @dtEventos  
	order by TipoEvento asc
GO
