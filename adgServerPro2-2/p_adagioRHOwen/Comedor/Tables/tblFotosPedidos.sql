USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblFotosPedidos](
	[IDFotoPedido] [int] IDENTITY(1,1) NOT NULL,
	[FotoUrl] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IdentifyResults] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Pedidos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDsPedidos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRestaurante] [int] NULL,
	[Valido] [bit] NULL,
	[Mensaje] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaRegistro] [datetime] NULL,
 CONSTRAINT [Pk_ComedorTblFotosPedidos_IDFotoPedido] PRIMARY KEY CLUSTERED 
(
	[IDFotoPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblFotosPedidos] ADD  CONSTRAINT [D_ComedorTblFotosPedidos_Valido]  DEFAULT ((0)) FOR [Valido]
GO
ALTER TABLE [Comedor].[tblFotosPedidos] ADD  CONSTRAINT [D_ComedorTblFotosPedidos_FechaRegistro]  DEFAULT (getdate()) FOR [FechaRegistro]
GO
ALTER TABLE [Comedor].[tblFotosPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblCatRestaurante_ComedorTblFotosPedidos_IDRestaurante] FOREIGN KEY([IDRestaurante])
REFERENCES [Comedor].[tblCatRestaurantes] ([IDRestaurante])
ON DELETE CASCADE
GO
ALTER TABLE [Comedor].[tblFotosPedidos] CHECK CONSTRAINT [Fk_ComedorTblCatRestaurante_ComedorTblFotosPedidos_IDRestaurante]
GO
