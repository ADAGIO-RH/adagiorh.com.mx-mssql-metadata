USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblPedidosAutorizadosAutomaticamente](
	[IDPedido] [int] NOT NULL,
	[Numero] [int] NOT NULL,
	[IDRestaurante] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDEmpleadoRecibe] [int] NULL,
	[Autorizado] [bit] NULL,
	[IDEmpleadoAutorizo] [int] NULL,
	[IDUsuarioAutorizo] [int] NULL,
	[FechaHoraAutorizacion] [datetime] NULL,
	[ComandaImpresa] [bit] NULL,
	[FechaHoraImpresion] [datetime] NULL,
	[DescontadaDeNomina] [bit] NULL,
	[FechaHoraDescuento] [datetime] NULL,
	[IDPeriodo] [int] NULL,
	[Cancelada] [bit] NULL,
	[NotaCancelacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCancelacion] [datetime] NULL,
	[FechaCreacion] [date] NULL,
	[HoraCreacion] [time](7) NULL,
	[GrandTotal] [money] NULL,
	[NotaAutorizacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuarioCancelo] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
