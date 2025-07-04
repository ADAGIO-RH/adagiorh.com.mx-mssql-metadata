USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ELE].[tblServicioEmpleados](
	[IDServicioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoServicio] [int] NOT NULL,
	[Catalogo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCatalogo] [int] NULL,
	[Descripcion] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha] [date] NOT NULL,
	[TiempoFecha] [time](7) NULL,
	[TiempoDecimal] [decimal](18, 2) NULL,
	[IDUsuarioRegistro] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDServicioEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ELE].[tblServicioEmpleados] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO
ALTER TABLE [ELE].[tblServicioEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_tblServicioEmpleados_IDTipoServicio] FOREIGN KEY([IDTipoServicio])
REFERENCES [ELE].[tblCatTiposServicios] ([IDTipoServicio])
GO
ALTER TABLE [ELE].[tblServicioEmpleados] CHECK CONSTRAINT [FK_tblServicioEmpleados_IDTipoServicio]
GO
